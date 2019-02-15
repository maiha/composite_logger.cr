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
class Logger
  def formatter=(str : String)
    @formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
      io << str.gsub(/\{\{([^=}]+)=?(.*?)\}\}/) {
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
    end
  end

  def level=(str : String)
    self.level = Logger::Severity.parse(str)
  end
end
