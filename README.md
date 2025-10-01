# Rosetta

<p align="center">
  <img src="https://wout.github.io/rosetta/v0.9.0/assets/rosetta-logo-accent.png"
       width="256"
       alt="Rosetta logo">
</p>

A blazing fast internationalization (i18n) library for Crystal with compile-time
key lookup. You'll never have a `missing translation` in your app, ever again.

![GitHub](https://img.shields.io/github/license/wout/rosetta)
![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/wout/rosetta)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/wout/rosetta/ci.yml?branch=main)

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

### Rosetta is more than 12x faster than similar libraries

Benchmarking against other libraries which also use YAML or JSON backends,
Rosetta is 12x to 700x faster than any other one.

For simple translations:

```
crimson-knight/i18n.cr translation 303.57k (  3.29µs) (± 4.62%)  801B/op  702.21× slower
     crystal-i18n/i18n translation  18.07M ( 55.35ns) (± 7.28%)  48.0B/op  12.39× slower
         syeopite/lens translation   5.09M (196.47ns) (± 4.60%)   176B/op  43.98× slower
          wout/rosetta translation 223.86M (  4.47ns) (± 2.20%)   0.0B/op        fastest
```

For translations with interpolations:

```
crimson-knight/i18n.cr interpolation 318.12k (  3.14µs) (± 0.85%)    801B/op  108.51× slower
     crystal-i18n/i18n interpolation  65.55k ( 15.26µs) (± 1.01%)  28.2kB/op  664.37× slower
         syeopite/lens interpolation   2.04M (490.17ns) (± 1.35%)    565B/op   21.35× slower
          wout/rosetta interpolation  43.55M ( 22.96ns) (± 4.81%)   80.0B/op         fastest
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

4. Require the generated config file:

```cr
# src/app_name.cr
require "../config/rosetta"
```

5. Include the `Rosetta::Translatable` mixin:

```cr
# src/pages/main_layout.cr
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

## Development

Make sure you have [Guardian.cr](https://github.com/f/guardian) installed. Then
run:

```bash
guardian
```

This will automatically:

- run ameba for src and spec files
- run the relevant spec for any file in src
- run spec file whenever they are saved
- install shards whenever you save shard.yml

## Documentation

- [Reference](https://wout.github.io/rosetta/latest)
- [API Docs](https://wout.github.io/rosetta/api/main)

## Contributing

### To the lib

1. Fork it (<https://github.com/wout/rosetta/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### To the docs

Check out the `docs` branch and run the following command to launch the docs locally:

```
docker run --rm -it -p 8000:8000 -v ${PWD}:/docs squidfunk/mkdocs-material
```

## Contributors

- [wout](https://github.com/wout) - creator and maintainer

## Acknowledgements

This shard pulls inspiration from the following projects:

- [crimson-knight/i18n.cr](https://github.com/crimson-knight/i18n.cr)
- [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n)
- [syeopite/lens](https://github.com/syeopite/lens)
- [ruby-i18n/i18n](https://github.com/ruby-i18n/i18n)
