# Configuration
Configuration options are defined as constants in your initializer file.

## `DEFAULT_LOCALE`
Defines the default value if no locale is set. The *default* default locale is
set to `:en`.

```cr
Rosetta::DEFAULT_LOCALE = "es-ES"
```

The value can be either a `String` or a `Symbol`.

🗒️ **Note**: The default locale is used by the compiler to define the ruling set
of locale keys. This means that, if one of the other available locales is
missing some of the keys found in the default key set, the compiler will
complain. So every available locale will need to have the exact same key set as
the default locale.

## `AVAILABLE_LOCALES`
Defines all the available locales, including the default locale. The default
for this setting is `%i[en]`.

```cr
Rosetta::AVAILABLE_LOCALES = %i[de en-GB en-US es nl]
```

## `FALLBACKS`

TODO: Fallbacks still need to be implemented.
