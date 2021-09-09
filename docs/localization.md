Predefined localization formats, day names and month names, live under the
`rosetta_localization` namespace in the locale files. The initializer script
will install the required files for you in order to be able to work with
Rosetta.

## Localized time
Similar to translations, localization formats are fetched at compile-time and 
localized at runtime.

```cr
Rosetta.time.l(Time.local)
# => "Sun, 29 Aug 2021 18:30:57 +0200"
```

This will use the `:default` format to convert the given `Time` object. Another predefined format can be passed:

```cr
Rosetta.time(:short).l(Time.local)
# => "29 Aug 18:30"
```

For specific formats, a string can be passed as well:

```cr
Rosetta.time("%H:%M:%S").l(Time.local)
# => "18:30:57"
```

## Localized date
```cr
Rosetta.date.l(Time.local)
# => "2021-08-29"
```

Or with a date-formatted tuple:

```cr
Rosetta.date.l({1991, 9, 17})
# => "1991-09-17"
```

Similar to the `time` macro, a predefined format can be passed:

```cr
Rosetta.date(:long).l(Time.local)
# => "August 29, 2021"
```

Or a completely custom format:

```cr
Rosetta.date("%Y").l(Time.local)
# => "2021"
```

## Localized number
Number formats work the same as date and time formats.

```cr
Rosetta.number.l(123_456.789)
# => "123,456.79"
```

With a specific predefined format:

```cr
Rosetta.number(:custom).l(123_456.789)
# => "12 34 56.789"
```

Or with specific formatting options:

```cr
Rosetta.number.l(123_456.789, decimal_places: 6)
# => "123,456.789000"
```

!!! info
    In the background, Rosetta uses Crystal's native `Number#format` method and
    accepts the same parameters.

## The `Localizable` mixin
Include this mixin anywhere you want to work with localized dates, times and
numbers. Here's an example of its usage:

```cr
class User
  include Rosetta::Localizable

  def birthday
    r_date(:short).l(born_at)
  end
end

User.new.birthday
# => "Feb 20"
```

Similarly there are the `r_time` and the `r_number` macros for retrieval,
returning a struct which accepts the `l` method for the value that needs to be
localized.
