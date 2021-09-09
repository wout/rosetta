## Arguments and `NamedTuple`

Interpolations can be passed as arguments for the `t` method:
```cr
Rosetta.find("user.welcome_message").t(name: "Ary")
# => "Hi Ary!"
```

A `NamedTuple` works as well:

```cr
Rosetta.find("user.welcome_message").t({name: "Ary"})
# => "Hi Ary!"
```

Important to know here is that translations with interpolation keys will always
require you to call the `t` method with the right number of interpolation keys,
or the compiler will complain:

```cr
# en.user.welcome_message: "Hi %{name}!"
Rosetta.find("user.welcome_message").t

Error: wrong number of arguments for 'Rosetta::Locales::User_WelcomeMessage#t'
(given 0, expected 1)

Overloads are:
 - Rosetta::Locales::User_WelcomeMessage#t(name : String)
 - Rosetta::Locales::User_WelcomeMessage#t(values : NamedTuple(name: String))
```

This is to ensure you're not missing any interpolation values.

## Time directives
If the string in your locale files contains time format directives, Rosetta will
require a time object as one of the interpolation arguments and translate the
value to the current locale:

```cr
# es.messages.great_day: "¡Hola %{name}, que tengas un buen %A!"
Rosetta.find("messages.great_day").t(name: "Brian", time: Time.local)
# => "¡Hola Brian, que tengas un buen domingo!"
```

## Working with a `Hash`
The `t` method does not accept hashes, only arguments or a `NamedTuple`. For
situations where you have to use a hash, there's the `t_hash` method:

```cr
Rosetta.find("user.welcome_message").t_hash({ :name => "Beta" })
# => "Hi Beta!"
```

However, this method is considered unsafe because the content of hashes can't be
checked at compile-time. It's also much slower, because interpolation values are
inserted using `gsub` instead of native string interpolation. So, only use it
when there's no other way, and use it with care.

## The uninterpolated string
The raw, uninterpolated string, can be accessed with the `raw` method:

```cr
Rosetta.find("user.welcome_message").raw
# => "¡Hola %{name}, que tengas un buen %A!"
```

Which can then be interpolated later:

```cr
value = Rosetta.find("messages.great_day").raw
# => "¡Hola %{name}, que tengas un buen %A!"
Rosetta.interpolate(value, {name: "Ary", time: Time.local})
# => "¡Hola Ary, que tengas un buen domingo!"
```

Note that the `Rosetta.interpolate` method uses `gsub` rather than native string
interpolation, so it's a lot slower and it doesn't check if all the required
interpolation keys are given.
