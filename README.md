# Rosetta

A Crystal library for internationalization with compile-time key lookup.

## Description

Rosetta is different from other internationalization libraries because it
handles key lookup at compile-time rather than runtime. The significant
advantage is that you'll be able to find missing localizations - or typos in
your locale keys - during development rather than after you've deployed your
app.

But that's not all. Rosetta will even compare the locale keys of additional
(localized) languages to those of your primary language. Any missing or
additional keys will be reported in development. A CLI utility will make it
easy to add those reports to your CI flow, so you'll no longer have to worry
about deploying an app with missing translations.

**IMPORTANT: This shard is still under heavy development and is not ready for
use.**

## Installation

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  rosetta:
    github: wout/rosetta
```

2. Run `shards install`

## Usage

```crystal
require "rosetta"
```

TODO: Coming soon!

## Development

TODO: Coming soon!

## Contributing

1. Fork it (<https://github.com/wout/rosetta/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [wout](https://github.com/wout) - creator and maintainer
