After loading all locales, the parser does a series of checkes on the given set.

## Check 1: presence of translations for all locales
If the full set of translations is missing for a locale in the configured
`Rosetta::AvailableLocales` annotation, the parser will raise an error similar
to the following:

```bash
Error: Expected to find translations for:

  ‣ en
  ‣ nl
  ‣ fr

But missing all translations for:

  ‣ fr
```

## Check 2: presence of ruling key set in all alternative locales
The `Rosetta::DefaultLocale` annotation will define the key set that should be
present in every alternative locale. If keys are missing, you'll get an error
like the one below:

```bash
Error: Missing keys for locale "nl":

  ‣ user.first_name
  ‣ user.gender.male
  ‣ user.gender.female
  ‣ user.gender.non_binary
```

## Check 3: no additional keys in alternative locales
If any of the alternative locales has keys that aren't present in the key set 
of the `Rosetta::DefaultLocale` annotation, the parser will raise an error:

```bash
Error: The "nl" locale has unused keys:

  ‣ user.name
  ‣ user.date_of_birth
```

## Check 4: interpolation keys are present in every translation
If a translation in the `Rosetta::DefaultLocale` has one or more interpolation
keys, then those interpolation keys should also be present in the alternative
locales. If not, an error similar to the following will be raised:

```bash
Error: Some translations have mismatching interpolation keys:

  ‣ nl: "message.welcome" should contain "%{first_name}"
  ‣ nl: "base.validations.min_max" should contain "%{min}"
  ‣ nl: "base.validations.min_max" should contain "%{max}"
  ‣ fr: "message.welcome should" contain "%{first_name}"
```

## Check 5: pluralization tags are present in every translations
Every pluralization rule has a `Rosetta::Pluralization::CategoryTags` annotation
defining which tags should be present in every pluralizable translation. If they
are not, an error will be raised:

```bash
Error: Some pluralizable translations are missing category tags:
  ‣ en: "basket.items" is missing "one"
  ‣ nl: "inbox.messages" is missing "few"
```
