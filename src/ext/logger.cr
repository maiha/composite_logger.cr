# Add new features to `Logger`
# - `formatter=(str : String)` 
# - `level=(str : String)`
#
# ```crystal
# logger.formatter = "{{mark}}, [{{time=%H:%M}}] {{prog=[%s] }}{{message}}"
# logger.info "foo", "main" # => "I, 23:57 [main] foo"
#
# logger.level = "INFO"
# logger.level # => Logger::Severity::INFO
# ```

require "colorize"

class Logger
  property colorize : Bool = false
  @exact_level : Bool = false

  def self.new(io : IO?, level : String, formatter : Formatter | String = DEFAULT_FORMATTER, progname = "") : Logger
    logger = new(io, progname: progname)
    logger.level = level
    logger.formatter = formatter
    return logger
  end

  def formatter=(str : String)
    @formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
      msg = str.gsub(/\{\{([^=}]+)=?(.*?)\}\}/) {
        key = $1
        fmt = $2.empty? ? nil : $2
        begin
          v = case key
              when "mark"              ; severity.to_s[0]
              when "severity", "level" ; severity
              when "datetime", "time"  ; datetime
              when "progname", "prog"  ; progname
              when "message"           ; message
              when "pid"               ; Process.pid
              else                     ; "{{#{key}}}"
              end
          if v.is_a?(Time)
            fmt ? v.to_s(fmt) : v.to_s
          else
            if fmt && !v.to_s.empty?
              fmt % v
            else
              v.to_s
            end
          end
        rescue err
          "{{#{key}:#{err}}}"
        end
      }
      if colorize
        case severity
        when .error?, .fatal?
          msg = msg.colorize(:red)
        when .warn?
          msg = msg.colorize(:yellow)
        end
      end
      io << msg
    end
  end

  def level=(str : String)
    case str
    when /^=(.*)$/
      @exact_level = true
      str = $1
    end
    self.level = Logger::Severity.parse(str)
  end

  # overwrites stdlib "src/logger.cr"
  def log(severity, message, progname = nil)
    return if severity < level || !@io
    return if @exact_level && severity != level
    write(severity, Time.local, progname || @progname, message)
  end

  def log(severity, progname = nil)
    return if severity < level || !@io
    return if @exact_level && severity != level
    write(severity, Time.local, progname || @progname, yield)
  end
end
