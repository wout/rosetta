# Configuration
Configuration options are defined as constants in your initializer file.

!!! warning
    All configuration should happen *before* calling the 
    `Rosetta::Backend.load` macro.

## `DEFAULT_LOCALE`
Defines the default value if no locale is set. The *default* default locale is
set to `:en`.

```cr
Rosetta::DEFAULT_LOCALE = "es-ES"
```

The value can be either a `String` or a `Symbol`.

!!! info
    The `DEFAULT_LOCALE` is used by the compiler to define the ruling set of
    locale keys. Which means that, if one of the other available locales is
    missing some of the keys found in the default key set, the compiler will
    complain. So every available locale will need to have the exact same key set
    as the default locale.

## `AVAILABLE_LOCALES`
Defines all the available locales, including the default locale. The default
for this setting is `%i[en]`.

```cr
Rosetta::AVAILABLE_LOCALES = %i[de en-GB en-US es nl]
```

## `PLURALIZATION_RULES`
Defines a custom mapping of pluralization rules:

```cr
Rosetta::PLURALIZATION_RULES = {
  en: MyRule,
  nl: MyRule,
}
```

## `FALLBACKS`

TODO: Fallbacks still need to be implemented.
