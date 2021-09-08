# Rosetta

A blazing fast internationalization (i18n) library for Crystal with compile-time
key lookup. You'll never have a `missing translation` in your app, ever again.

![GitHub](https://img.shields.io/github/license/wout/rosetta)

## Why use Rosetta?

### You'll never have a missing translation
Rosetta is different from other internationalization libraries because it
handles key lookup at compile-time rather than runtime. The significant
advantage is that you'll be able to find missing translations - or typos in
your locale keys - during development rather than after you've deployed your
app. This is also true for translation keys in all additional locales.

### You'll never have a missing interpolation
In Rosetta, interpolation keys are arguments to the translation method. So if
you're missing an argument, the compiler will complain. The parser will also
compare interpolation keys in additional locales to the ones found in the
default locale, and complain if some are missing.

### Rosetta is 10x faster than similar libraries
Benchmarking against other libraries which also use YAML or JSON files for
locales, Rosetta is about 10x faster than any other one.

For simple translations:

```
crimson-knight/i18n.cr translation 147.72k (  6.77µs) (± 3.36%) 0.99kB/op 178.77× slower
     crystal-i18n/i18n translation   2.25M (443.68ns) (± 3.44%)  48.0B/op  11.05× slower
         syeopite/lens translation   1.10M (912.67ns) (± 7.10%)   176B/op  22.72× slower
          wout/rosetta translation  24.89M ( 40.17ns) (± 6.59%)   0.0B/op         fastest

```

For translations with interpolations:

```
crimson-knight/i18n.cr interpolation 145.50k (  6.87µs) (± 4.47%)  0.99kB/op  23.12× slower
     crystal-i18n/i18n interpolation 138.84k (  7.20µs) (± 4.16%)  2.05kB/op  21.23× slower
         syeopite/lens interpolation 314.68k (  3.18µs) (± 7.30%)    561B/op   9.29× slower
          wout/rosetta interpolation   2.95M (339.26ns) (± 7.17%)   80.0B/op         fastest
```

Rosetta is that much faster because a lot of the hard work happens at
compile-time. And because the majority of the data is stored on the [stack
rather than the
heap](https://stackoverflow.com/questions/79923/what-and-where-are-the-stack-and-heap),
out of the scope of garbage collector.

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
Rosetta.locale = :es

class Hello::ShowPage < MainLayout
  def content
    h1 r("welcome_message").t(name: "Brian") # => "¡Hola Brian!"
  end
end
```

## Setup
The `bin/rosetta --init` command will generate the initial files to get started.

An initializer has the following content:

```cr
# config/rosetta.cr
require "rosetta"

Rosetta::DEFAULT_LOCALE = :en
Rosetta::AVAILABLE_LOCALES = %i[en]
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
set to `:en`.

```cr
Rosetta::DEFAULT_LOCALE = "es-ES"
```

🗒️ **Note**: The default locale is used by the compiler to define the ruling set
of locale keys. This means that, if one of the other available locales is
missing some of the keys found in the default key set, the compiler will
complain. So every available locale will need to have the exact same key set as
the default locale.

### `AVAILABLE_LOCALES`
Defines all the available locales, including the default locale. The default
for this setting is `%i[en]`.

```cr
Rosetta::AVAILABLE_LOCALES = %i[de en-GB en-US es nl]
```

### `FALLBACKS`

TODO: Fallbacks still need to be implemented.

## Usage

### Locale files
Chop up your locale files and place them in subdirectories; organise them any
way you prefer. Currently, Rosetta supports YAML and JSON files and you can mix
formats together.

🗒️ **Note**: Beware, though, that there is a fixed loading order. JSON files are
loaded first, then YAML files. So in the unlikely situation where you have the
same key in a JSON and a YAML file, YAML will take precedence.

### Lookup
Looking up translations is done with the `find` macro:

```cr
Rosetta.find("user.name")
```

This will return a struct containing all the translation data for the given key.
To get the translation for the currently selected locale, call the `l`
(localize) method:

```cr
Rosetta.find("user.name").t
# => "User name"
```

Optionally, you can call `to_s` or use the struct with string
interpolation:

```cr
Rosetta.find("user.name").to_s
# => "User name"

"#{Rosetta.find("user.name")}"
# => "User name"
```

The translation struct also includes the `Lucky::AllowedInTags` module, so it
works with Lucky templates as well, even without having to call `t`:

```cr
class Products::ShowPage < MainLayout
  def content
    h1 Rosetta.find(".heading")
  end
end
```

Wehn required, the translations for all locales can be accessed with the
`translations` property:

```cr
Rosetta.find("user.first_name").translations
# => {en: "First name", nl: "Voornaam"}
```

If a different locale needs to be used in a specific place, use the
`with_locale` method:

```cr
Rosetta.with_locale(:nl) do
  Rosetta.find("user.first_name").t
  # => "Voornaam"
end
```

### Interpolations
Interpolations can be passed as arguments for the `t` (for localize) method:

```cr
Rosetta.find("user.welcome_message").t(name: "Ary")
# => "Hi Ary!"
```

Important to know here is that translations with interpolation keys will always
require you to call the `t` method with the right number of interpolation keys,
or the compiler will complain:

```cr
# user.welcome_message: "Hi %{name}!"
Rosetta.find("user.welcome_message").t

Error: wrong number of arguments for 'Rosetta::Locales::User_WelcomeMessage#t'
(given 0, expected 1)

Overloads are:
 - Rosetta::Locales::User_WelcomeMessage#t(name : String)
 - Rosetta::Locales::User_WelcomeMessage#t(values : NamedTuple(name: String))
```

This is to ensure you're not missing any interpolation values.

The raw, uninterpolated string, can be accessed with the `raw` method:

```cr
Rosetta.find("user.welcome_message").raw
# => "Hi %{name}!"
```

One final note on interpolations. The `t` method does not accept hashes, only
arguments or a `NamedTuple`. For situations where you have to use a hash,
there's the `t_hash` method:

```cr
Rosetta.find("user.welcome_message").t_hash({ :name => "Beta" })
# => "Hi Beta!"
```

However, this method is considered unsafe because the content of hashes can't be
checked at compile-time. Only use it when there's no other way, and use it with
care.

### The `Translatable` mixin
This mixin makes it more convenient to work with translated values in your
classes. Here's an example of its usage:

```cr
Rosetta.locale = :es

class User
  include Rosetta::Translatable

  def name_label
    r("user.name_label").t
  end
end

User.new.name_label
# => "Nombre"
```

The `r` macro essentially is an alias for the `Rosetta.find` macro.

Inferred locale keys make it even more concise. By omitting the prefix of the
locale key and having the key start with a `.`, the key prefix will be
derived from the current class name:

```cr
class User
  include Rosetta::Translatable

  def name_label
    r(".name_label").t # => resolves to "user.name_label"
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
    r(".name_label").t # => resolves to "guest.name_label"
  end
end
```

Just like the global `Rosetta.find` marco, interpolations are passed using the
`t` method:

```cr
class User
  include Rosetta::Translatable

  def welcome_message
    r(".welcome_message").t(name: "Ary")
  end
end
```

The `r` macro uses `Rosetta.find` to get the translations for a given key at
compile-time. Then the `t` method localizes the value at runtime.

### Date, time and numeric localization
Localization instructions live under a the `rosetta_localization` namespace in
the locale files. The initializer script will install the required files for you
in order to be able to work with Rosetta.

#### Localized time
Similar to translations, localization formats are retrieved at compile-time and 
localized at runtime.

```cr
Rosetta.time.l(Time.local)
# => "Sun, 29 Aug 2021 18:30:57 +0200"
```

This will use the `:default` format to convert the given `Time` object. Another predefined format can be passed:

```cr
Rosetta.time(:short).l(Time.local)
# => "29 Aug 18:30"
```

For specific formats, a string can be passed as well:

```cr
Rosetta.time("%H:%M:%S").l(Time.local)
# => "18:30:57"
```

#### Localized date
```cr
Rosetta.date.l(Time.local)
# => "2021-08-29"
```

Or with a date-formatted tuple:

```cr
Rosetta.date.l({1991, 9, 17})
# => "1991-09-17"
```

Similar to the `time` macro, a predefined format can be passed:

```cr
Rosetta.date(:long).l(Time.local)
# => "August 29, 2021"
```

Or a completely custom format:

```cr
Rosetta.date("%Y").l(Time.local)
# => "2021"
```

#### Localized number
Number formats work the same as date and time formats.

```cr
Rosetta.number.l(123_456.789)
# => "123,456.79"
```

With a specific predefined format:

```cr
Rosetta.number(:custom).l(123_456.789)
# => "12 34 56.789"
```

Or with specific formatting options:

```cr
Rosetta.number.l(123_456.789, decimal_places: 6)
# => "123,456.789000"
```

🗒️ **Note**: In the background, Rosetta uses Crystal's native `Number#format`
method and accepts the same parameters.

### The `Localizable` mixin
Include this mixin anywhere you want to work with localized dates, times and
numbers. Here's an example of its usage:

```cr
class User
  include Rosetta::Localizable

  def birthday
    r_date(:short).l(born_at)
  end
end

User.new.birthday
# => "Feb 20"
```

Similarly there are the `r_time` and the `r_number` macros for retrieval,
returning a struct which accepts the `l` method for the value that needs to be
localized.

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
- [X] Translatable mixin
- [X] Localization of numeric values
- [X] Localization of date and time values
- [X] Localizable mixin
- [X] Locale exceptions
- [X] Add setup scripts
- [ ] Pluralization (with one/many/other/count/... convention)
- [ ] Implement fallbacks

## Development

Make sure you have [Guardian.cr](https://github.com/f/guardian) installed. Then
run:

```bash
$ guardian
```

This will automatically:
- run ameba for src and spec files
- run the relevant spec for any file in src
- run spec file whenever they are saved
- install shards whenever you save shard.yml

## Documentation

- [API (main)](https://wout.github.io/rosetta/)

## Contributing

1. Fork it (<https://github.com/wout/rosetta/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [wout](https://github.com/wout) - creator and maintainer
