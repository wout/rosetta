# Configuration
Configuration options are defined as annotations to the main `Rosetta` module in
the initializer file.

!!! warning
    All configuration should happen *before* calling the 
    `Rosetta::Backend.load` macro.

## `Rosetta::DefaultLocale`
Defines the default value if no locale is set. The *default* default locale is
set to `:en`.

```cr
@[Rosetta::DefaultLocale("es-ES")]
module Rosetta
end
```

The value can be either a `String` or a `Symbol`.

!!! info
    This value is used by the compiler to define the ruling set of locale keys.
    Which means that, if one of the other available locales is missing some of
    the keys found in the default key set, the compiler will complain. So every
    available locale will need to have the exact same key set as the default
    locale.

## `Rosetta::AvailableLocales`
Defines all the available locales, including the default locale. The default
for this setting is `["en"]`.

```cr
@[Rosetta::AvailableLocales("de", "en-GB", "en-US", "es", "nl")]
module Rosetta
end
```

## `Rosetta::PluralizationRules`
Defines a custom mapping of pluralization rules:

```cr
@[Rosetta::PluralizationRules({
  en: MyRule,
  nl: MyRule,
})]
module Rosetta
end
```
