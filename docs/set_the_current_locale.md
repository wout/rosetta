## Globally
If no value is set, the value of the `Rosetta.default_locale` macro will be
used. This macro will first look if `Rosetta::DEFAULT_LOCALE` is defined, and if
it is not, it will fall back to an internal value (`:en`).

Defining the current locale is done as folows:

```cr
Rosetta.locale = :es
```

This property accepts a `String` or a `Symbol`. But note that the getter variant
of this property will always return a string:

```cr
Rosetta.locale = :nl
Rosetta.locale
# => "nl"
```

If the given locale identifier is not present in the array returned by the
`Rosetta.available_locales` macro, the value of the `Rosetta.default_locale`
macro will be used instead:

```cr
Rosetta::DEFAULT_LOCALE = :es
Rosetta.locale = :xx
Roestta.locale
# => "es"
```

## Locally
Sometimes you'll want to use a different locale for a specific part of your
code. In that case, use the `Rosetta.with_locale` method:

```cr
Rosetta.find("user.first_name").t
# => First name

Rosetta.with_locale(:nl) do
  Rosetta.find("user.first_name").t
  # => "Voornaam"
end

Rosetta.find("user.first_name").t
# => First name
```