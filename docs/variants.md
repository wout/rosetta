## Runtime variants
When working with html selects or lists from a database that need translating,
it's not possible to use compile-time key lookup. That's where variants come in.

Variants are similar to pluralizations as in that they're a locale key
containing multiple values:

```yaml
en:
  color_variants:
    pink: "Millennial pink"
    teal: "Deep teal"
    yellow: "Bright yellow"
```

If the key name contains the `_variants` suffix, Rosetta will treat it as a
translation with variants. They `t()` method for translations with variants will
then require a `variant` argument:

```cr
Rosetta.find("color_variants").t(variant: "pink")
# => "Millennial pink"
```

One disadvantage of variants is that their lookup happens at runtime, so you'll
have to make sure all variants are present in the locale files.

## Compile-time variants
Runtime variants can be avoided if the variant keys are known at compile-time.
Given the following translations:

```yaml
en:
  colors:
    pink: "Millennial pink"
    teal: "Deep teal"
    yellow: "Bright yellow"
```

A macro can be used to build the locale keys:

```cr
{% begin %}
  {% for variant in %w[pink teak yellow] %}
    Rosetta.find("colors.{{variant.id}}").t
  {% end %}
{% end %}
```
