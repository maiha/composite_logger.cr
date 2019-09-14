# composite_logger.cr [![Build Status](https://travis-ci.org/maiha/composite_logger.cr.svg?branch=master)](https://travis-ci.org/maiha/composite_logger.cr)

Logger interface to write to multiple loggers for [Crystal](http://crystal-lang.org/).
In addition, this extends handy methods to stdlib `Logger`.

```crystal
require "composite_logger"

logger = CompositeLogger.new
logger << Logger.new(STDOUT, level: "=INFO")
logger << Logger.new(STDERR, level: ">INFO")
logger << Logger.new("err.log", level: "ERROR")

logger.warn("API: HTTP 500")
logger.error("DB: file not found")
logger.info("done")
```

```
--- STDOUT ---
done
--- STDERR ---
API: HTTP 500
DB: file not found
--- err.log ---
DB: file not found
```

#### API

```crystal
class CompositeLogger < Logger
  def initialize(loggers : Array(Logger), ...)

class Logger
  def colorize=(bool : Bool)
  def formatter=(fmt : String)
  def level=(str : String)
  def level_op=(op : LevelOp)
```

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  composite_logger:
    github: maiha/composite_logger.cr
    version: 0.3.2
```

## Usage (CompositeLogger)

### logging to both STDOUT, STDERR and FILE

already described in top usage.

### in memory logging

`memory:` option provides a handy in-memory logging.

```crystal
logger = CompositeLogger.new(memory: Logger::ERROR)
...
unless logger.memory.to_s.empty?
  STDERR.puts "Some errors occurred while running program."
  exit -1
end
```

## Usage (Logger extensions)

### `Logger#colorize = true`

This library enhanced stdlib `Logger` to colorize messages.

- ERROR, FATAL: red
- WARN: yellow

This is enabled only when `colorize == true` and `formatter=` is used.

```crystal
logger.formatter = "{{message}}"
logger.colorize = true
logger.error "foo" # => "\e[31mfoo\e[0m\n"
```

### `Logger#formatter=(fmt : String)`

This library enhanced stdlib `Logger#formtter=` to accept format string.

The traditional way to set formatter is not pretty.
```crystal
logger.formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
  io << severity.to_s << "," << message
end
logger.info "foo" # => "INFO,foo\n"
```

This can be simply refactored by `{{KEYWORD(=FORMAT)}}` as follows.
```crystal
logger.formatter = "{{severity}},{{message}}"
logger.info "foo" # => "INFO,foo\n"
```

##### available keywords

|Keyword           |Alias     | Converted to          | Example               |
|------------------|----------|-----------------------|-----------------------|
|`{{level}}`       |`severity`|`severity`             | "INFO"                |
|`{{level=[%-5s]}}`|          |`severity`             | "[INFO ]"             |
|`{{mark}}`        |          |`severity.to_s[0]`     | "I"                   |
|`{{time}}`        |`datetime`|`datetime`             | "2019-01-24 21:03:45" |
|`{{time=%H:%M}}`  |          |`datetime.to_s("...")` | "21:03"               |
|`{{prog}}`        |`progname`|`progname`             | "main"                |
|`{{message}}`     |          |`message`              | "foo"                 |
|`{{pid=%6s}}`     |          |`Process.pid`          | "  5361"              |
|`{{xxx}}`         |          | (leaves unknowns)     | "{{xxx}}"             |

The default formatter in stdlib can be represented as follows.
```crystal
"{{mark}}, [{{time}}\#{{pid}}] {{prog=%s: }}{{message}}"
```

### `Logger#level=(str : String)`

This library enhanced stdlib `Logger#level=` to accept level string for handy accessor.

```crystal
logger = Logger.new(nil)
logger.level = "DEBUG"
```

In addition, it provides a **level op** as level quantifier.

```crytsal
logger = Logger.new(STDOUT, level: "=INFO")
logger.info "foo" # Of course stored
logger.warn "foo" # ignored **(NEW)**
```

##### available quantifier

- `>=`(default), `=`, `>`, `<`, `<=`, `<>`, `!=`(same as `<>`)

## Contributing

1. Fork it (<https://github.com/maiha/composite_logger.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- maiha(https://github.com/maiha) maiha - creator, maintainer
