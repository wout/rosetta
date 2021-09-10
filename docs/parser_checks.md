After loading all locales, the parser does a series of checkes on the given set.

## Check 1: presence of translations for all locales
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

## Check 2: presence of ruling key set in all alternative locales
The `DEFAULT_LOCALE` will define the key set that should be present in every
alternative locale. If keys are missing, you'll get an error like the one below:

```bash
Error: Missing keys for locale "nl":

  ‣ user.first_name
  ‣ user.gender.male
  ‣ user.gender.female
  ‣ user.gender.non_binary
```

## Check 3: no additional keys in alternative locales
If any of the alternative locales has keys that aren't present in the key set 
of the `DEFAULT_LOCALE`, the parser will raise an error:

```bash
Error: The "nl" locale has unused keys:

  ‣ user.name
  ‣ user.date_of_birth
```

## Check 4: interpolation keys are present in every translation
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