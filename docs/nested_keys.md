## Reusing existing translations

Sometimes you may want to reuse values from other translations keys to avoid
duplication. That's where nested keys come in handy. Other keys can be
referenced using the `%r{}` directive:

```yaml
en:
  messages:
    greeting: "Hello %r{messages.world}!"
    goodbye: "Goodbye %r{messages.world}!"
    world: "world"
```

The parser will check the existence of nested keys at compile time and let you
know if any of them could not be found.

!!! warning

    Key nesting does not work recursively, so you can't reference a locale key
    that in itself references another locale key.

    It's also not possible to use two nested keys. Please consider creating a
    PR or opening an issue it that's something you need.
