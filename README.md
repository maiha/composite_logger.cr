# composite_logger.cr [![Build Status](https://travis-ci.org/maiha/composite_logger.cr.svg?branch=master)](https://travis-ci.org/maiha/composite_logger.cr)

Logger interface to write to multiple loggers for [Crystal](http://crystal-lang.org/).

```crystal
logger = CompositeLogger.new(loggers)
logger.info("hello")
# => (stdout) "hello"
# => (a file) "hello"
```

In addition, this add a `Logger#formatter=(str : String)` method to core library.
See: [src/ext/logger.cr](./src/ext/logger.cr)

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  composite_logger:
    github: maiha/composite_logger.cr
    version: 0.3.1
```

## Usage

```crystal
require "composite_logger"
```

### logging to both File and STDOUT

```crystal
loggers = [
  Logger.new(STDOUT),
  Logger.new(File.open("app.log")),
]
logger = CompositeLogger.new(loggers)
logger.info("hello")
```

### in memory logging

`memory:` option provides a handy in-memory logging.

```crystal
loggers = [Logger.new(STDOUT)]
logger = CompositeLogger.new(loggers, memory: Logger::ERROR)
...
unless logger.memory.to_s.empty?
  STDERR.puts "Some errors occurred while running program."
  exit -1
end
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
|`{{name}}`        |`progname`|`progname`             | "main"                |
|`{{message}}`     |          |`message`              | "foo"                 |
|`{{pid=%6s}}`     |          |`Process.pid`          | "  5361"              |
|`{{xxx}}`         |          | (leaves unknowns)     | "{{xxx}}"             |

## Contributing

1. Fork it (<https://github.com/maiha/composite_logger.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- maiha(https://github.com/maiha) maiha - creator, maintainer
