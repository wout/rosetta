## Lookup
Looking up translations is done with the `find` macro:

```cr
Rosetta.find("user.name")
```

This will return a struct containing all the translation data for the given key.
To get the translation for the currently selected locale, call the `t` method:

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

## Getting all `translations`
When required, the translations for all locales can be accessed with the
`translations` property:

```cr
Rosetta.find("user.first_name").translations
# => {en: "First name", nl: "Voornaam"}
```

## The `Translatable` mixin
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

The `r` macro essentially is an alias for the `Rosetta.find` macro, but it
introduces the possibility to use inferred locale keys. By omitting the prefix
of the locale key and having the key start with a `.`, the key prefix will be
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
compile-time. Then the `t` method translates the value at runtime.
