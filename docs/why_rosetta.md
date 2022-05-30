# Why use Rosetta?

## You'll never have a missing translation
Rosetta is different from other internationalization libraries because it
handles key lookup at compile-time rather than runtime. The significant
advantage is that you'll be able to find missing translations - or typos in
your locale keys - during development rather than after you've deployed your
app. This is also true for translation keys in all additional locales.

## You'll never have a missing interpolation
In Rosetta, interpolation keys are arguments to the translation method. So if
you're missing an argument, the compiler will complain. The parser will also
compare interpolation keys in additional locales to the ones found in the
default locale, and let you know if some are missing.

## Rosetta is 12x faster than similar libraries
Benchmarking against other libraries which also use YAML or JSON backends,
Rosetta is more than 12x faster than any other one.

For simple translations:

```
i18n.cr translation 303.57k (  3.29µs) (± 4.62%)  801B/op  702.21× slower
   i18n translation  18.07M ( 55.35ns) (± 7.28%)  48.0B/op  12.39× slower
   lens translation   5.09M (196.47ns) (± 4.60%)   176B/op  43.98× slower
rosetta translation 223.86M (  4.47ns) (± 2.20%)   0.0B/op        fastest
```

For translations with interpolations:

```
i18n.cr interpolation 318.12k (  3.14µs) (± 0.85%)    801B/op  108.51× slower
   i18n interpolation  65.55k ( 15.26µs) (± 1.01%)  28.2kB/op  664.37× slower
   lens interpolation   2.04M (490.17ns) (± 1.35%)    565B/op   21.35× slower
rosetta interpolation  43.55M ( 22.96ns) (± 4.81%)   80.0B/op         fastest
```

Rosetta is that much faster because a lot of the hard work happens at
compile-time, and the majority of the data is stored on the [stack
rather than the
heap](https://stackoverflow.com/questions/79923/what-and-where-are-the-stack-and-heap),
out of the scope of garbage collector.

!!! info
    Libraries used in benchmarks are [crimson-knight/i18n.cr](https://github.com/crimson-knight/i18n.cr), [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n) and [syeopite/lens](https://github.com/syeopite/lens).
