# Rosetta

<p align="center">
  <img src="https://wout.github.io/rosetta/v0.1.0/assets/rosetta-logo-accent.png" width="256" alt="Rosetta logo">
</p>


A blazing fast internationalization (i18n) library for Crystal with compile-time
key lookup. You'll never have a `missing translation` in your app, ever again.

![GitHub](https://img.shields.io/github/license/wout/rosetta)
![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/wout/rosetta)
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/wout/rosetta/Rosetta%20CI)

## Why use Rosetta?

### You'll never have a missing translation
Rosetta is different from other internationalization libraries because it
handles key lookup at compile-time rather than runtime. The significant
advantage is that you'll be able to find missing translations - or typos in
your locale keys - during development rather than after you've deployed your
app. This is also true for translation keys in all additional locales.

### You'll never have a missing interpolation
In Rosetta, interpolation keys are arguments to the translation method. So if
you're missing an argument, the compiler will complain. The parser will also
compare interpolation keys in additional locales to the ones found in the
default locale, and complain if some are missing.

### Rosetta is 10x faster than similar libraries
Benchmarking against other libraries which also use YAML or JSON backends,
Rosetta is about 10x faster than any other one.

For simple translations:

```
crimson-knight/i18n.cr translation 147.72k (  6.77µs) (± 3.36%) 0.99kB/op 178.77× slower
     crystal-i18n/i18n translation   2.25M (443.68ns) (± 3.44%)  48.0B/op  11.05× slower
         syeopite/lens translation   1.10M (912.67ns) (± 7.10%)   176B/op  22.72× slower
          wout/rosetta translation  24.89M ( 40.17ns) (± 6.59%)   0.0B/op         fastest

```

For translations with interpolations:

```
crimson-knight/i18n.cr interpolation 145.50k (  6.87µs) (± 4.47%)  0.99kB/op  23.12× slower
     crystal-i18n/i18n interpolation 138.84k (  7.20µs) (± 4.16%)  2.05kB/op  21.23× slower
         syeopite/lens interpolation 314.68k (  3.18µs) (± 7.30%)    561B/op   9.29× slower
          wout/rosetta interpolation   2.95M (339.26ns) (± 7.17%)   80.0B/op         fastest
```

Rosetta is that much faster because a lot of the hard work happens at
compile-time. And because the majority of the data is stored on the [stack
rather than the
heap](https://stackoverflow.com/questions/79923/what-and-where-are-the-stack-and-heap),
out of the scope of garbage collector.

Read more on [the official docs page](https://wout.github.io/rosetta/latest).

## Installation

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  rosetta:
    github: wout/rosetta
```

2. Run `shards install`

3. Run `bin/rosetta --init`

4. Require the shard

```cr
# src/shards.cr
require "rosetta"
```

5. Include the `Rosetta::Translatable` mixin

```cr
# e.g. src/pages/main_layout.cr
include Rosetta::Translatable
```

6. Localize your app

```cr
Rosetta.locale = :es

class Hello::ShowPage < MainLayout
  def content
    h1 r("welcome_message").t(name: "Brian") # => "¡Hola Brian!"
  end
end
```

Read more on [the official docs page](https://wout.github.io/rosetta/latest).

## To-do
- [x] Add specs for the existing code
- [x] Make settings accessible to the compiler
- [x] Send `default_locale` and `available_locales` to the parser
- [x] Implement key comparison between available locales in the parser
- [x] Add compiler error messages for mismatching keys
- [x] Implement inferred locale keys at macro level
- [x] Interpolation (with %{} tag for interpolation keys)
- [x] Check existence of interpolation keys in all translations at compile-time
- [x] Translatable mixin
- [x] Localization of numeric values
- [x] Localization of date and time values
- [x] Localizable mixin
- [x] Locale exceptions
- [x] Add setup scripts
- [x] Pluralization (with one/many/other/count/... convention)
- [ ] Implement fallbacks

## Development

Make sure you have [Guardian.cr](https://github.com/f/guardian) installed. Then
run:

```bash
$ guardian
```

This will automatically:
- run ameba for src and spec files
- run the relevant spec for any file in src
- run spec file whenever they are saved
- install shards whenever you save shard.yml

## Documentation

- [Reference](https://wout.github.io/rosetta/main)
- [API Docs](https://wout.github.io/rosetta/api/main)

## Contributing

1. Fork it (<https://github.com/wout/rosetta/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [wout](https://github.com/wout) - creator and maintainer

## Acknowledgements
This shard pulls inpiration from the following projects:
- [crimson-knight/i18n.cr](https://github.com/crimson-knight/i18n.cr)
- [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n)
- [syeopite/lens](https://github.com/syeopite/lens)
- [Rails](https://github.com/rails/rails)
