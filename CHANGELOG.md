# Changelog

## 0.3.0 (2021-09-24)

- Change the argument order of `Rosetta.localize_time` to be more consistent
  with the rest of the lib.
- Add `Rosetta::Parser::Config` to be able to work with YAML configurations sent
  from the backend.
- Rework the parser to be able to deal with multi-option translations for a
  single locale key.
- Move parser checks to the `Rosetta::Parser::Checks` module.
- Add parser check to validate the pluralization category tags in every
  pluralizable translation.
- Add the `Rosetta::PluralizedTranslation` mixin to be able to work with
  pluralizable translations.
- Rework `Rosetta::Backend` to send a single YAML configuration to the parser
  rather than separate arguments.
- Add locale/pluralization rule mapping in `Rosetta::Pluralization::DEFAULT_RULES`
  (borrowed from [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n)).
- Add most common pluralization rules under `rosetta/pluralization/rule`
  (borrowed from [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n)).
- Add the `Rosetta::Pluralization::Rule` base class.
- Add the `Rosetta::Pluralization::CategoryTags` annotation to inform the parser
  about which category tags are required per pluralization rule.

## 0.2.0 (2021-09-10)

- Add `Rosetta::Lucky.integrate` to easily include `Rosetta::Treanslatable`
  where localizations may be used.
- Create `Rosetta::SimpleTranslation` and `Rosetta::InterpolatedTranslation`
  mixins to simplify the builder.
- Raise a compile error when translations with interpolations are converted to
  string using Crystal string interpolation or by calling `to_s`.

## 0.1.0 (2021-09-08)

Initial release of Rosetta with documentation.
