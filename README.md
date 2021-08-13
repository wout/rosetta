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

You can chop up locale files and place them in subdirectories; organise them any
way you prefer. Currently, Rosetta supports YAML and JSON files and you can mix
formats together. So if you started out with JSON and later on decided to use
YAML instead, there is no need to convert your old files. Rosetta will gladly
parse both formats.

🗒️ **Note**: Beware, though, that there is a fixed loading order. JSON files
are loaded first, then YAML files. So if you have the same key in a JSON and a
YAML file, YAML will take precedence.

## Configuration
Configuration options are set as constants in your initializer file.

### `DEFAULT_LOCALE`
Defines the default value if no locale is set. The *default* default locale is
set to `"en"`.

```cr
module Rosetta
  DEFAULT_LOCALE = "es-ES"
end
```

🗒️ **Note**: The default locale is used by the compiler to define the ruling set
of locale keys. This means that, if one of the other available locales is
missing some of the keys found in the default key set, the compiler will
complain. So every available locale will need to have the exact same key set as
the default locale.

### `AVAILABLE_LOCALES`
Defines all the available locales, including the default locale. The default
for this setting is `%w[en]`.

```cr
module Rosetta
  AVAILABLE_LOCALES = %w[de en-GB en-US es nl]
end
```

### `FALLBACKS`

TODO: Fallbacks still need to be implemented.

## Usage

### Global lookup
Looking up translations is done in two phases. The first phase happens at
compile-time, where an object with all translations for a given key is fetched:

```cr
name_translations = Rosetta.find("user.name")
# => { "en" => "Name", "es" => "Nombre", "nl" => "Naam" }
```

🗒️ **Note**: If a key does not exist, the compiler will let you know.

The second phase happens at runtime where the translation for the currently
selected locale is retreived:

```cr
dutch_translation = Rosetta.t(name_translations)
# => "Naam"
```

🗒️ **Note**: Translations for all available locales will always be present.

In practie, you'll probably chain those two phases together:

```cr
Rosetta.t(Rosetta.find("user.name"))
```

Of course, this is pretty long to write out for every single value that needs to
be translated. Enter the `Translator`.

### The `Translator`
This mixin makes it more convenient to work with translated values. Here's an
example of its usage:

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
is equivalent to `Rosetta.t`.

Inferred locale keys make it even more concise. By omitting the prefix of the
locale key and having the key start with a period, the key prefix will be
derived from the current class name:

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

Using inferred locale keys has an added bonus. You don't need to think about how
to organise your locale files. And it makes finding your keys a lot easier.

## To-do
- [X] Add specs for the existing code
- [X] Make settings accessible to the compiler
- [ ] Send `default_locale` and `available_locales` to the parser
- [ ] Implement key comparison between available locales in the parser
- [ ] Add compiler error messages for mismatching keys
- [ ] Implement inferred locale keys on macro level
- [ ] Implement fallbacks
- [ ] Interpolation (with %{} tag for interpolation keys)
- [ ] Pluralization (with one/other/count convention)

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
