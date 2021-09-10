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

## Rosetta is 10x faster than similar libraries
Benchmarking against other libraries which also use YAML or JSON backends,
Rosetta is about 10x faster than any other one.

For simple translations:

```
i18n.cr translation 147.72k (  6.77µs) (± 3.36%) 0.99kB/op 178.77× slower
   i18n translation   2.25M (443.68ns) (± 3.44%)  48.0B/op  11.05× slower
   lens translation   1.10M (912.67ns) (± 7.10%)   176B/op  22.72× slower
rosetta translation  24.89M ( 40.17ns) (± 6.59%)   0.0B/op         fastest

```

For translations with interpolations:

```
i18n.cr interpolation 145.50k (  6.87µs) (± 4.47%)  0.99kB/op  23.12× slower
   i18n interpolation 138.84k (  7.20µs) (± 4.16%)  2.05kB/op  21.23× slower
   lens interpolation 314.68k (  3.18µs) (± 7.30%)    561B/op   9.29× slower
rosetta interpolation   2.95M (339.26ns) (± 7.17%)   80.0B/op         fastest
```

Rosetta is that much faster because a lot of the hard work happens at
compile-time, and the majority of the data is stored on the [stack
rather than the
heap](https://stackoverflow.com/questions/79923/what-and-where-are-the-stack-and-heap),
out of the scope of garbage collector.

!!! info
    Libraries used in benchmarks are [crimson-knight/i18n.cr](https://github.com/crimson-knight/i18n.cr), [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n) and [syeopite/lens](https://github.com/syeopite/lens).
