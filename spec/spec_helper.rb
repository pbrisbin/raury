require 'stringio'

def capture_stdout(&block)
  $stdout = s = StringIO.new

  yield

  s.string

ensure
  $stdout = STDOUT
end
