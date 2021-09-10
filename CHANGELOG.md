# Changelog

## 0.2.0 (2021-09-10)

- Add `Rosetta::Lucky.integrate` to easily include `Rosetta::Treanslatable`
  where localizations may be used.
- Create `Rosetta::SimpleTranslation` and `Rosetta::InterpolatedTranslation`
  mixins to simplify the builder.
- Raise a compile error when translations with interpolations are converted to
  string using Crystal string interpolation or by calling `to_s`.

## 0.1.0 (2021-09-08)

Initial release of Rosetta with documentation.
