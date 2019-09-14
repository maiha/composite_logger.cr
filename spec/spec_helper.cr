require "spec"
require "../src/composite_logger"

def messages_in(io : IO::Memory) : Array(String)
  ary = io.to_s.chomp.gsub(/^.*? -- : (.*?)$/m){$1}.split(/\n/)
  (ary == [""]) ? Array(String).new : ary
end
