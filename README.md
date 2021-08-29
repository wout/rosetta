# Rosetta

A Crystal library for internationalization with compile-time key lookup. You'll
never have a `missing translation` in your app, ever again.

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

3. Run `bin/rosetta --init`

4. Require the shard

```cr
# src/shards.cr
require "rosetta"
```

5. Include the `Rosetta::Translatable` mixin

```cr
# e.g. src/pages/main_layout.cr
include Rosetta::Translatable
```

6. Localize your app

```cr
Rosetta.locale = "es"

class Hello::ShowPage < MainLayout
  def content
    h1 t("welcome_message").with(name: "Brian") # => "¡Hola Brian!"
  end
end
```

## Setup
The `bin/rosetta --init` command will generate the initial files to get started.

An initializer has the following content:

```cr
# config/rosetta.cr
require "rosetta"

module Rosetta
  DEFAULT_LOCALE = "en"
  AVAILABLE_LOCALES = %w[en]
end

Rosetta::Backend.load("config/rosetta")
```

An example locale file:

```yaml
# config/rosetta/example.en.yml
en:
  welcome_message: "Hi %{name}!" 
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

### Lookup
Looking up translations is done with the `t` macro:

```cr
Rosetta.t("user.name")
```

**Note**: the return value of the `t` macro needs to be converted to a string.
If you're using Lucky, you're in luck (pun intended). The returned object
includes the `Lucky::AllowedInTags` module, so there's no need to call `to_s`.
But in a context where `to_s` isn't called, you'll need to take care of that
yourself:
```
Rosetta.t("user.name").to_s
# => "User name"
```

### Interpolations
Interpolations can be passed by using the `with` method on the value returned by
the `t` macro:

TO-DO: what about passing objects using the with method?

```cr
Rosetta.t("user.welcome_message").with(name: "Ary")
# => "Hi Ary!"
```

Important to know here is that translations with interpolation keys will always
require you to call the `with` method, or the compiler will complain:

```cr
# user.welcome_message: "Hi %{name}!"
Rosetta.t("user.welcome_message").to_s

Error: wrong number of arguments for 'Rosetta::Locales::User::WelcomeMessage#with' (given 0, expected 1)

Overloads are:
 - Rosetta::Locales::User::WelcomeMessage#with(name : String)
```

This is to ensure you're not missing any interpolation values.

### The `Translatable` mixin
This mixin makes it more convenient to work with translated values in your
classes. Here's an example of its usage:

```cr
Rosetta.locale = "es"

class User
  include Rosetta::Translatable

  def name_label
    t("user.name_label")
  end
end

User.new.name_label.to_s
# => "Nombre"
```

Inferred locale keys make it even more concise. By omitting the prefix of the
locale key and having the key start with a `.`, the key prefix will be
derived from the current class name:

```cr
class User
  include Rosetta::Translatable

  def name_label
    t(".name_label") # => resolves to "user.name_label"
  end
end
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
    t(".name_label") # => resolves to "guest.name_label"
  end
end
```

Just like the global `t` marco, interpolations are passed using the `with`
method:

```cr
class User
  include Rosetta::Translatable

  def welcome_message
    t(".welcome_message").with(name: "Ary")
  end
end
```

### Localization
Rosetta supports localization for a time, a date or a number. Localization
instructions live under a the `rosetta_localization` namespace in the locale
files. The initializer script will install the required files for you in order
to be able to work with Rosetta.

#### Localized time
```cr
Rosetta.time.with(Time.local)
# => "Sun, 29 Aug 2021 18:30:57 +0200"
```

This will use the `:default` format to convert the given `Time` object. Another predefined format can be passed:

```cr
Rosetta.time(:short).with(Time.local)
# => "29 Aug 18:30"
```

For specific formats, a string can be passed as well:

```cr
Rosetta.time("%H:%M:%S").with(Time.local)
# => "18:30:57"
```

#### Localized date
```cr
Rosetta.date.with(Time.local)
# => "2021-08-29"
```

Or with a date-formatted tuple:

```cr
Rosetta.date.with({1991, 9, 17})
# => "1991-09-17"
```

Similar to the `time` macro, a predefined format can be passed:

```cr
Rosetta.time(:long).with(Time.local)
# => "August 29, 2021"
```

Or a a specific format:

```cr
Rosetta.time("%Y").with(Time.local)
# => "2021"
```

#### Localized number
```cr
Rosetta.number.with(123_456.789)
# => "123,456.79"
```

With a specific predefined format:

```cr
Rosetta.number(:custom).with(123_456.789)
# => "12 34 56.8"
```



## Parser checks
After loading all locales, the parser does a series of checkes on the given set.

### Check 1: presence of translations for all locales
If the full set of translations is missing for a locale in the configured
`AVAILABLE_LOCALES`, the parser will raise an error similar to the following:

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

### Check 4: interpolation keys are present in every translation
If a translation in the `DEFAULT_LOCALE` has one or more interpolation keys,
then those interpolation keys should also be present in the alternative locales.
If not, an error similar to the following will be raised:

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
- [X] Localization of date and time values
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
