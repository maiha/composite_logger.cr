# composite_logger.cr [![Build Status](https://travis-ci.org/maiha/composite_logger.cr.svg?branch=master)](https://travis-ci.org/maiha/composite_logger.cr)

Logger interface to write to multiple loggers for [Crystal](http://crystal-lang.org/).

```crystal
logger = CompositeLogger.new(loggers)
logger.info("hello")
# => (stdout) "hello"
# => (a file) "hello"
```

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  composite_logger:
    github: maiha/composite_logger.cr
    version: 0.3.0
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

## Contributing

1. Fork it (<https://github.com/maiha/composite_logger.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- maiha(https://github.com/maiha) maiha - creator, maintainer
