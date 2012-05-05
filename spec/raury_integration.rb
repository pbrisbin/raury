# This test shouldn't be run regularly. It actually hits the AUR and
# relies on real search results (at least for now). That said, it is a
# true integration test as it confirms searching works from commandline
# to stdout.
require 'raury'
require 'spec_helper'

describe Raury do
  it "prints short search results" do
    stdout = capture_stdout { Raury::Main.run! ['-s', 'aur', 'helper'] }

    stdout.chomp.should eq(%{
aur/aur77i-git 20120410-1
    another tiny incompatible aur helper for the masses
aur/mate-file-manager-makepkg 2.30.0-1 [out of date]
    An AUR helper for the MATE file manager context menu
aur/nautilus2-makepkg 2.30.0-2
    An AUR helper for the nautilus context menu
aur/pkgbuilder 2.1.2.20-1
    A basic Python AUR helper/library.
aur/powaur 0.1.6-1
    An AUR helper with a pacman-like interface
aur/spinach 0.5.0-2
    A small AUR helper written in Bash.
aur/tusdah 0.9.1-1
    The Ultimate Super Duper Aur Helper
    }.strip)
  end

  it "prints info results" do
    stdout = capture_stdout { Raury::Main.run! ['-i', 'aurget', 'cower'] }

    stdout.chomp.should eq(%{
Repository      : aur
Name            : aurget
Version         : 3.4.0-2
URL             : http://pbrisbin.com/posts/aurget/
Out of date     : No
Description     : A simple Pacman-like interface to the AUR

Repository      : aur
Name            : cower
Version         : 5-1
URL             : http://github.com/falconindy/cower
Out of date     : No
Description     : A simple AUR agent with a pretentious name
    }.strip + "\n")
  end

  it "prints pkgbuilds" do
    stdout = capture_stdout { Raury::Main.run! ['-p', 'aurget', 'cower'] }

    stdout.chomp.should eq(%{
# Author: Patrick Brisbin <pbrisbin@gmail.com>
pkgname=aurget
pkgver=3.4.0
pkgrel=2
pkgdesc="A simple Pacman-like interface to the AUR"
arch=('any')
url="http://pbrisbin.com/posts/$pkgname/"
license="GPL" 
backup=(etc/aurgetrc)
conflicts=('aurget-git' 'aurget-jordz')
install=aurget.install
source=($pkgname aurgetrc bash_completion)
depends=('sudo' 'curl' 'ca-certificates')
optdepends=('customizepkg: for auto-customizing packages')

# todo: empty build(), use package()
build() { 
  # install script
  install -D -m755 ./$pkgname "$pkgdir/usr/bin/$pkgname" || return 1

  # add rc file
  mkdir -p "$pkgdir/etc/"
  install -m644 ./aurgetrc "$pkgdir/etc/aurgetrc"

  # add completion file
  mkdir -p "$pkgdir/etc/bash_completion.d/"
  install -m644 ./bash_completion "$pkgdir/etc/bash_completion.d/aurget"
}
md5sums=('6a00e20ad72e6c378b1ecde74112d0ff'
         '3374a830198c439af6b98c7b263f83dc'
         'c97eaedb6bfce0cc250da66348e83651')

# Maintainer: Dave Reisner <d@falconindy.com>

pkgname=cower
pkgver=5
pkgrel=1
pkgdesc="A simple AUR agent with a pretentious name"
arch=('i686' 'x86_64')
url="http://github.com/falconindy/cower"
license=('MIT')
depends=('curl' 'yajl' 'pacman')
makedepends=('perl')
source=("https://github.com/downloads/falconindy/$pkgname/$pkgname-$pkgver.tar.gz")
md5sums=('9db2a09c7f828d6eeb436a534ae17311')

build() {
  make -C "$pkgname-$pkgver"
}

package() {
  make -C "$pkgname-$pkgver" PREFIX=/usr DESTDIR="$pkgdir" install
}

# vim: ft=sh syn=sh
    }.strip + "\n")
  end

  it "prints quiet search results" do
    stdout = capture_stdout { Raury::Main.run! ['-s', '-q', 'aur', 'helper'] }

    stdout.chomp.should eq(%{
aur77i-git
mate-file-manager-makepkg
nautilus2-makepkg
pkgbuilder
powaur
spinach
tusdah
    }.strip)
  end

  it "prints quiet info results" do
    stdout = capture_stdout { Raury::Main.run! ['-i', '-q', 'aurget', 'cower'] }

    stdout.chomp.should eq(%{
aurget
cower
    }.strip)
  end

  it "prints quiet pkgbuild results" do
    stdout = capture_stdout { Raury::Main.run! ['-p', '-q', 'aurget', 'cower'] }

    stdout.chomp.should eq(%{
aurget
cower
    }.strip)
  end
end
