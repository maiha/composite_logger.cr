require "./spec_helper"

describe "README" do
  it "works" do
    stdout = IO::Memory.new
    stderr = IO::Memory.new
    errlog = IO::Memory.new

    logger = CompositeLogger.new
    logger << Logger.new(stdout, level: "=INFO")
    logger << Logger.new(stderr, level: ">INFO")
    logger << Logger.new(errlog, level: "ERROR")

    logger.info("foo")  # (stdout) foo
    logger.warn("bar")  # (stderr) bar
    logger.error("baz") # (stderr) baz, (critical.log) baz

    messages_in(stdout).should eq(["foo"])
    messages_in(stderr).should eq(["bar", "baz"])
    messages_in(errlog).should eq(["baz"])
  end
end
