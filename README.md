# Rosetta

A Crystal library for internationalization with compile-time key lookup.

![GitHub](https://img.shields.io/github/license/wout/rosetta)

## Description

Rosetta is different from other internationalization libraries because it
handles key lookup at compile-time rather than runtime. The significant
advantage is that you'll be able to find missing translations - or typos in
your locale keys - during development rather than after you've deployed your
app.

The parser also compares all locale keys of additional (localized) languages
to those of your primary language. Any missing or additional keys will be
reported in development. So you'll no longer have to worry about deploying an
app with missing translations.

**IMPORTANT: This shard is still under heavy development and is not yet ready
for use.**

## Installation

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  rosetta:
    github: wout/rosetta
```

2. Run `shards install`

3. Require the shard and set up the required files

```cr
# src/shards.cr
require "rosetta"
```

```bash
lucky rosetta.init
``` 

Or if you're not using Lucky:

```bash
mkdir -p config/rosetta
echo -e 'en:\n  welcome_message: "Hello %{name}!"' >> config/rosetta/en.yml
echo -e 'es:\n  welcome_message: "¡Hola %{name}!"' >> config/rosetta/es.yml
echo -e 'nl:\n  welcome_message: "Hallo %{name}!"' >> config/rosetta/nl.yml
# ... repeat for every available locale
touch config/rosetta.cr
```

```cr
# config/rosetta.cr
require "rosetta"

module Rosetta
  DEFAULT_LOCALE = "en"
  AVAILABLE_LOCALES = %w[en es nl]
end

Rosetta::Backend.load("config/rosetta")
```

4. Include the `Rosetta::Translatable` mixin

```cr
# e.g. src/pages/main_layout.cr
include Rosetta::Translatable
```

5. Localize your app

```cr
Rosetta.locale = "es"

class Hello::ShowPage < MainLayout
  def content
    h1 t(rosetta("welcome_message"), name: "Brian") # => "¡Hola Brian!"
  end
end
```

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

### Locale files
You can chop up locale files and place them in subdirectories; organise them any
way you prefer. Currently, Rosetta supports YAML and JSON files and you can mix
formats together. So if you started out with JSON and later on decided to use
YAML instead, there is no need to convert your old files. Rosetta will gladly
parse both formats.

🗒️ **Note**: Beware, though, that there is a fixed loading order. JSON files
are loaded first, then YAML files. So if you have the same key in a JSON and a
YAML file, YAML will take precedence.

### Global lookup
Looking up translations is done in two phases. The first phase happens at
compile-time, where an object with all translations for a given key is fetched
(hence *Rosetta*):

```cr
name_translations = Rosetta.find("user.name")
# => { "en" => "Name", "es" => "Nombre", "nl" => "Naam" }
```

🗒️ **Note**: If a key does not exist, the compiler will let you know.

The second phase happens at runtime where the translation for the currently
selected locale is retreived:

```cr
Rosetta.locale = "nl"

dutch_translation = Rosetta.t(name_translations)
# => "Naam"
```

🗒️ **Note**: Translations for all available locales will always be present at this point.

In practie, you'll probably chain those two phases together:

```cr
Rosetta.t(Rosetta.find("user.name"))
```

Interpolations are accepted as a `Hash`, a `NamedTuple` or as arguments:

```cr
# with a Hash
Rosetta.t(Rosetta.find("user.welcome_message"), { "name" => "Ary" })

# with a NamedTuple
Rosetta.t(Rosetta.find("user.welcome_message"), { name: "Ary" })

# or with arguments
Rosetta.t(Rosetta.find("user.welcome_message"), name: "Ary")
```

Of course, this is pretty long to write out for every single value that needs to
be translated. Enter the `Translatable` mixin.

### The `Translatable` mixin
This mixin makes it more convenient to work with translated values in your
classes. Here's an example of its usage:

```cr
Rosetta.locale = "es"

class User
  include Rosetta::Translatable

  def name_label
    t rosetta("user.name_label")
  end
end

User.new.name_label
# => "Nombre"
```

The `rosetta` macro does exactly the same as `Rosetta.find`, and the `t` method
is equivalent to `Rosetta.t`.

Inferred locale keys make it even more concise. By omitting the prefix of the
locale key and having the key start with a `.`, the key prefix will be
derived from the current class name:

```cr
class User
  include Rosetta::Translatable

  def name_label
    t rosetta(".name_label") # => resolves to "user.name_label"
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
to organise your locale files. And it also makes finding your keys a lot easier.

Finally, in case you want to use another prefix for the current class, a
constant can be used:

```cr
class User
  include Rosetta::Translatable

  ROSETTA_PREFIX = "guest"

  def name_label
    t rosetta(".name_label") # => resolves to "guest.name_label"
  end
end

User.new.name_label
# => "Guest"
```

And interpolations are accepted as arguments, as a `Hash` or as a `NamedTuple`:

```cr
class User
  include Rosetta::Translatable

  def welcome_message
    t rosetta(".welcome_message"), name: "Ary"
  end
end

User.new.welcome_message
# => "Hola Ary, ¡eres un mago!"
```

## Compiler errors
After loading all locales, the parser does a series of checkes on the given set.

### Check 1: presence of translations for all locales
If you configured the `AVAILABLE_LOCALES` setting to be `%w[en fr nl]`, but
translations for one locale are missing, the parser will raise the following
error:

```bash
Error: Expected to find translations for:

  ‣ en
  ‣ nl
  ‣ fr

But missing all translations for:

  ‣ fr
```

### Check 2: presence of ruling key set in all alternative locales
The `DEFAULT_LOCALE` will define the key set that should be present in every
alternative locale. If keys are missing, you'll get an error like the one below:

```bash
Error: Missing keys for locale "nl":

  ‣ user.first_name
  ‣ user.gender.male
  ‣ user.gender.female
  ‣ user.gender.non_binary
```

### Check 3: no additional keys in alternative locales
If any of the alternative locales has keys that aren't present in the key set 
of the `DEFAULT_LOCALE`, the parser will raise an error:

```bash
Error: The "nl" locale has unused keys:

  ‣ user.name
  ‣ user.date_of_birth
```

### Check 4: interpolation keys are present in every locale
If a translation in the `DEFAULT_LOCALE` has one or more interpolation keys,
then those interpolation keys should also be present in the alternative locales.
If not, the following error will be thrown:

```bash
Error: Some translations have mismatching interpolation keys:

  ‣ nl: message.welcome should contain "%{first_name}"
  ‣ nl: base.validations.min_max should contain "%{min}"
  ‣ nl: base.validations.min_max should contain "%{max}"
  ‣ fr: message.welcome should contain "%{first_name}"
```

## To-do
- [X] Add specs for the existing code
- [X] Make settings accessible to the compiler
- [X] Send `default_locale` and `available_locales` to the parser
- [X] Implement key comparison between available locales in the parser
- [X] Add compiler error messages for mismatching keys
- [X] Implement inferred locale keys at macro level
- [X] Interpolation (with %{} tag for interpolation keys)
- [X] Check existence of interpolation keys in all translations at compile-time
- [ ] Implement fallbacks
- [ ] Localization of numeric values
- [ ] Localization of date and time values
- [ ] Pluralization (with one/many/other/count/... convention)
- [ ] Add setup scripts for Lucky and other frameworks

## Development

TODO: Coming soon!

## Documentation

- [API (main)](https://wout.github.io/rosetta)

## Contributing

1. Fork it (<https://github.com/wout/rosetta/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [wout](https://github.com/wout) - creator and maintainer
