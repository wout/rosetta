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
of locale keys. This means that if one of the other available locales is missing
some of the keys found in the key set of the default locale, the compiler will
complain. So every available locale will need to have the exactr same key set as
the default locale.

### `available_locales`
Defines all the available locales, including the default locale. The default
`available_locales` is set to `%w[en]`.

```cr
Rosetta.settings.available_locales = %w[de en-GB en-US es nl]
```

### `fallbacks`

TODO: Fallbacks still need to be implemented.

## Usage

### Global lookup
Looking up translations is done in two phases. The first phase happens at
compile-time, where an object with all translations for a given key is fetched:

```cr
name_translations = Rosetta.find("user.name")
# => { "en" => "Name", "es" => "Nombre", "nl" => "Naam" }
```

🗒️ **Note:**: If a key does not exist, the compiler will let you know.

The second phase happens at runtime where the translation for the currently
selected locale is retreived:

```cr
dutch_translation = Rosetta.t(name_translations)
# => "Naam"
```

In practie, you'll probably chain twose two phases togeter:

```cr
Rosetta.t(Rosetta.find("user.name"))
```

Of course, this is pretty long to write out for every single valye that needs to
be translated. Enter the `Translator`.

### The `Translator`
This mixin makes it more conventient to work with translated values. Here's an
example of it's usage:

```cr
Rosetta.locale = "es"

class User
  include Rosetta::Translator

  def name_label
    t rosetta("user.name")
  end
end

User.new.name_label
# => "Nombre"
```

The `rosetta` macro does exactly the same as `Rosetta.find`, and the `t` method
does is equivalent to `Rosetta.t`.

But you can make it even shorter with inferred locale keys. By omitting the
prefix of the locale key and having the key start with a period, the current
class name will be used as the prefix of the key:

```cr
class User
  include Rosetta::Translator

  def name_label
    t rosetta(".name") # => resolves to "user.name"
  end
end

User.new.name_label
# => "Nombre"
```

This also works with nested class names, for example:

- `User` => `"user"`
- `Components::MainMenu` => `"components.main_menu"`
- `Helpers::SiteSections::UserSettings` => `"helpers.site_sections.user_settings"`


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
