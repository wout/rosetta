## Pluralizable locales
A pluralization in the locale files may look like the one below:

```cr
en:
  example:
    pluralization:
      one: "One item"
      other: "%{count} items"
```

The parser will interpret a translation as a pluralizable one if it contains a
key called `other`, and its value contains a `%{count}` interpolation key.

!!! info
    The `zero` category tag is a special case because it is optional in almost
    all pluralization rules. If it is present in the locale files and `count` is
    `0`, the value for `zero` will be used. If not, then Rosetta will fall back
    to `other`.

## Category tags
All the short category tags defined by [the
CLDR](http://cldr.unicode.org/index/cldr-spec/plural-rules) are supported:

- `zero`
- `one` (singular)
- `two` (dual)
- `few` (paucal)
- `many` (also used for fractions if they have a separate class)
- `other` (required—general plural form—also used if the language only has a
  single form)

## Pluralizable translations
For pluralizable translations, the `t` method will require the `count` argument,
which can be a `Float` or an `Int`:

```cr
Rosetta.find("example.pluralization").t(count: 1)
# => "One item"
Rosetta.find("example.pluralization").t(count: 12)
# => "12 items"
```

## Pluralization rules
Rosetta includes pluralization rules for most of the available locales. They can
be found in the repo under
[src/rosetta/pluralization/rule](https://github.com/wout/rosetta/tree/main/src/rosetta/pluralization/rule).

## Custom pluralization rules
Custom rules need to inherit from `Rosetta::Pluralization::Rule`, define the
`apply` method and define the required `CategoryTags` annotation. For example:

```cr
@[CategoryTags(:one, :few, :other)]
struct MyRule < Rosette::Pluralization::Rule
  def apply(count : Float | Int) : Symbol
    case count
    when 1
      :one
    when 2..5
      :few
    else
      :other
    end
  end
end
```

!!! info
    The `CategoryTags` annotation is used by the parser to check if the required
    category tags are all present in the pluralizable translations. If the
    annotation is not defined, the compiler will let you know. Since `zero` is
    optional, only include it if it should be required everywhere.

!!! info
    In some languages, `one` can be `0` or `1` (look at the `OneWithZeroOther`
    rule). If a custom rule should act in a similar way, include the
    `Rosetta::Pluralization::RelativeZero` module to avoid the hard fallback to 
    `:zero` when `0` is given.

In the initializer Rosetta created at setup, register the rule for one or more
locales:

```cr
Rosetta::PLURALIZATION_RULES = {
  en: MyRule,
  nl: MyRule,
}
```

!!! warning
    Configuring custom rules should happen before calling the
    `Rosetta::Backend.load` macro.