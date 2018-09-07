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

  it "accepts a logger too" do
    CompositeLogger.new(Logger.new(nil))
    CompositeLogger.new(Logger.new(nil), memory: Logger::ERROR)
  end
  
  it "accepts a composite logger too" do
    composite = CompositeLogger.new(Logger.new(nil))
    CompositeLogger.new(composite)
    CompositeLogger.new(composite, memory: Logger::ERROR)
  end
  
  describe "#memory" do
    it "provides as a handy in-memory logging" do
      loggers = [Logger.new(nil)]
      logger = CompositeLogger.new(loggers, memory: Logger::ERROR)

      logger.info("info")
      logger.memory.to_s.empty?.should be_true

      logger.error("error")
      logger.memory.to_s.empty?.should be_false
    end

    it "raises when no memory options are given" do
      loggers = [Logger.new(nil)]
      logger = CompositeLogger.new(loggers)

      expect_raises(Exception, /Memory logger is not enabled/) do
        logger.memory
      end
    end
  end
end
