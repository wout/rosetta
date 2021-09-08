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
# user.welcome_message: "Hi %{name}!"
Rosetta.find("user.welcome_message").t

Error: wrong number of arguments for 'Rosetta::Locales::User_WelcomeMessage#t'
(given 0, expected 1)

Overloads are:
 - Rosetta::Locales::User_WelcomeMessage#t(name : String)
 - Rosetta::Locales::User_WelcomeMessage#t(values : NamedTuple(name: String))
```

This is to ensure you're not missing any interpolation values.

## Working with a `Hash`
The `t` method does not accept hashes, only arguments or a `NamedTuple`. For
situations where you have to use a hash, there's the `t_hash` method:

```cr
Rosetta.find("user.welcome_message").t_hash({ :name => "Beta" })
# => "Hi Beta!"
```

However, this method is considered unsafe because the content of hashes can't be
checked at compile-time. Only use it when there's no other way, and use it with
care.

## The uninterpolated string
The raw, uninterpolated string, can be accessed with the `raw` method:

```cr
Rosetta.find("user.welcome_message").raw
# => "Hi %{name}!"
```