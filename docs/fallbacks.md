When working with variations of lanuages, like `en-US` or `en-GB`, it's useful
for one locale set to fall back on another one. Using fallbacks, you can avoid
duplication between your locales sets.

## Fallback rules

Fallback rules are configured using the `Rosetta::FallbackRules` annotation:

```crystal
@[Rosetta::AvailableLocales("en-GB", "en-US", :nl)]
@[Rosetta::FallbackRules({
  "en-GB": "en-US",
})]
```

In the example above, `en-US` is treated as the main locale set for English,
which should be complete. The `en-GB` set only needs to include the translations
deviating from `en-US`.

## Chaining fallbacks

Fallbacks may also be chained:

```crystal
@[Rosetta::AvailableLocales("en-GB", "en-US", :en, :nl)]
@[Rosetta::FallbackRules({
  "en-US": "en"
  "en-GB": "en-US",
})]
```

The callback change will now be `en-GB -> en-US -> en`.

!!! info
    It's important to note that fallback rules are applied sequentially. To be
    able to fall back to a set, it must be "complete". That is why, in the
    example above, `en-US` is falling back on `en` first, before `en-GB` can
    fall back on `en-US`.

