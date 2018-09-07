require "./spec_helper"

private def messages_in(io) : Array(String)
  ary = io.to_s.chomp.gsub(/^.*? -- : (.*?)$/m){$1}.split(/\n/)
  (ary == [""]) ? Array(String).new : ary
end

describe CompositeLogger do
  it "works with multiple loggers" do
    debug = IO::Memory.new
    info  = IO::Memory.new
    loggers = [
      Logger.new(debug).tap(&.level = Logger::DEBUG),
      Logger.new(info).tap(&.level = Logger::INFO),
    ]
    logger = CompositeLogger.new(loggers)
    logger.debug("debug")
    logger.info("info")

    messages_in(debug).should eq(["debug", "info"])
    messages_in(info).should eq(["info"])
  end

  describe "#memory" do
    it "works as a handy in-memory logger" do
      loggers = [Logger.new(STDOUT)]
      logger = CompositeLogger.new(loggers, memory: Logger::ERROR)

      logger.info("info")
      logger.memory.to_s.empty?.should be_true

      logger.error("error")
      logger.memory.to_s.empty?.should be_false
    end
  end
end
