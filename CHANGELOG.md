# Changelog

## 0.4.0 (2021-10-15)

- Add `Rosetta.distance_of_time_in_words` 
- Add `Rosetta.time_ago_in_words`
- Add `Rosetta.time_from_now_in_words`
- Add `Localizable#distance_of_time_in_words` 
- Add `Localizable#time_ago_in_words`
- Add `Localizable#time_from_now_in_words`
- Include `Rosetta::Localizable` everywhere using `Rosetta::Lucky.integrate`

## 0.3.2 (2021-09-26)

- Add better integration for Lucky pages (`Lucky::HTMLPage`).

## 0.3.1 (2021-09-26)

- Add a clearer compilation error message for the `r` macro.

## 0.3.0 (2021-09-25)

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
- Allow localization with a date-formatted tuple.

## 0.2.0 (2021-09-10)

- Add `Rosetta::Lucky.integrate` to easily include `Rosetta::Treanslatable`
  where localizations may be used.
- Create `Rosetta::SimpleTranslation` and `Rosetta::InterpolatedTranslation`
  mixins to simplify the builder.
- Raise a compile error when translations with interpolations are converted to
  string using Crystal string interpolation or by calling `to_s`.

## 0.1.0 (2021-09-08)

Initial release of Rosetta with documentation.