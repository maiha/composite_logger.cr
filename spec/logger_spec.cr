require "./spec_helper"

describe Logger do
  describe "#formatter=" do
    it "ensures backward compats" do
      io = IO::Memory.new
      logger = Logger.new(io)
      logger.formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
        io << severity.to_s << "," << message
      end
      logger.info "foo"
      io.to_s.should eq("INFO,foo\n")
    end

    it "also accepts String for handy settings" do
      io = IO::Memory.new
      logger = Logger.new(io)
      logger.formatter = "{{severity}},{{message}}"
      logger.info "foo"
      io.to_s.should eq("INFO,foo\n")
    end

    it "accepts '{{mark}}'" do
      apply("{{mark}}").should eq("I")
    end

    it "accepts '{{severity}}' and '{{level}}'" do
      apply("{{severity}}").should eq("INFO")
      apply("{{level}}").should eq("INFO")
    end

    it "accepts '{{datetime=FORMAT}}' and '{{time}}'" do
      apply("{{datetime=%Y}}").should eq(Time.now.to_s("%Y"))
      apply("{{time=%Y}}").should eq(Time.now.to_s("%Y"))
    end

    it "accepts '{{progname}}' and '{{prog}}'" do
      apply("{{progname}}").should eq("main")
      apply("{{prog}}").should eq("main")
    end

    it "accepts '{{message}}'" do
      apply("{{message}}").should eq("foo")
    end

    it "accepts '{{pid}}'" do
      apply("{{pid}}").should match(/^\d+$/)
    end

    it "accepts '{{KEYWORD=FORMAT}}'" do
      apply("{{severity}}").should eq("INFO")
      apply("{{severity=%5s}}").should eq(" INFO")
      apply("{{severity=%-5s}}").should eq("INFO ")
    end

    it "accepts '{{KEYWORD=FORMAT}}' and call format only when not empty" do
      apply("{{prog}}", "foo").should eq("foo")
      apply("{{prog=[%s]}}", "foo").should eq("[foo]")
      apply("{{prog=[%s]}}", "").should eq("")
    end

    it "leaves them alone for unknown keywords" do
      apply("{{xxx}}").should eq("{{xxx}}")
    end
  end

  describe "#level=" do
    it "accepts String" do
      logger = Logger.new(nil)
      logger.level.should eq(Logger::Severity::INFO)
      logger.level = "DEBUG"
      logger.level.should eq(Logger::Severity::DEBUG)
      logger.level = "info"
      logger.level.should eq(Logger::Severity::INFO)
    end

    it "raises when invalid string is given" do
      logger = Logger.new(nil)
      expect_raises(ArgumentError) do
        logger.level = "xxx"
      end
    end
  end
end

private def apply(fmt : String, prog = "main") : String
  io = IO::Memory.new
  logger = Logger.new(io)
  logger.formatter = fmt
  logger.info "foo", prog
  return io.to_s.chomp
end
