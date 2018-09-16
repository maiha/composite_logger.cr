require "logger"

class CompositeLogger < Logger
  include Enumerable(Logger)

  property loggers
  @memory : IO::Memory?
  
  def initialize(@loggers : Array(Logger), memory : Logger::Severity? = nil)
    if memory
      @memory = IO::Memory.new
      @loggers << Logger.new(@memory).tap(&.level = memory)
    end
    super(nil)
  end

  def memory? : IO::Memory?
    memory
  rescue
    nil
  end

  def memory : IO::Memory
    @memory || raise "Memory logger is not enabled"
  end

  delegate each, to: @loggers

  {% for method in %w( level= formatter= ) %}
    def {{method.id}}(v)
      each do |logger|
        logger.{{method.id}}(v)
      end
    end
  {% end %}

  {% for method in %w( close ) %}
    def {{method.id}}(*args)
      each do |logger|
        logger.{{method.id}}(*args)
      end
    end
  {% end %}

  {% for method in %w( debug info warn error fatal ) %}
    def {{method.id}}(*args, **options)
      each do |logger|
        logger.{{method.id}}(*args, **options)
      end
    end

    def {{method.id}}(*args, **options)
      each do |logger|
        logger.{{method.id}}(*args, **options) do |*yield_args|
          yield *yield_args
        end
      end
    end
  {% end %}
end

class CompositeLogger
  def self.new(logger : CompositeLogger, **args) : CompositeLogger
    CompositeLogger.new(logger.loggers, **args)
  end

  def self.new(logger : Logger, **args) : CompositeLogger
    CompositeLogger.new([logger], **args)
  end
end
