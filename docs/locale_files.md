# Locale files

```yaml
en:
  example:
    translation: "Hello world!"
    interpolation: "Hi %{name}, have a great %A!"
    pluralization:
      one: "One item"
      other: "%{count} items"
```

Chop up your locale files and place them in subdirectories. Use YAML or JSON
files, or mix them together. Organise them any way you prefer.

!!! warning
    Beware, though, that there is a fixed loading order. JSON files are loaded
    first, then YAML files. So in the unlikely situation where you have the same
    key in a JSON and a YAML file, YAML will take precedence.
