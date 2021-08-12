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

## Setup
Create an initializer to set up Rosetta:

```cr
require "rosetta"

Rosetta::Backend.load("config/locales")
```

You can chop up files and place them in subdirectories; organise them any way
you prefer. Currently, Rosetta supports YAML and JSON files. You can mix formats
together, so if you started out with JSON and later on decided to use YAML
instead, there is no need to convert your old files. Rosetta will gladly parse
both formats.

Beware, though, that there is a fixed loading order. First JSON files are
loaded, then YAML files. So if you have the same key in a JSON and a YAML file,
YAML will take precedence.

## Configuration
There are a few configuration options you can add to your initializer.

### `default_locale`
Defines the default value is no locale is set. The default `default_locale` is
set to `"en"`.

```cr
Rosetta.settings.default_locale = "de"
```

🗒️ **Note:** The default locale is used by the compiler to define the ruling set
of locale keys. This means if one of the other available locales is missing
some of the keys found in the key set of the default locale, the compiler will
complain. So every available locale will need to have all the keys from the
default locale.

### `available_locales`
Defines all the available locales, including the default locale. The default
`available_locales` is set to `%w[en]`.

```cr
Rosetta.settings.available_locales = %w[de en-GB en-US es nl]
```

### `fallbacks`

TODO: Fallbacks still need to be implemented.

## Usage

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
