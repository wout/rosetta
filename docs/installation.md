# Installation
### 1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  rosetta:
    github: wout/rosetta
```

### 2. Run `shards install`

### 3. Run `bin/rosetta --init`

### 4. Require the shard (optional)

```cr
# src/shards.cr
require "rosetta"
```

### 5. Include the `Rosetta::Translatable` mixin

```cr
# e.g. src/pages/main_layout.cr
include Rosetta::Translatable
```

### 6. Localize your app

```cr
Rosetta.locale = :es

class Hello::ShowPage < MainLayout
  def content
    h1 r("welcome_message").t(name: "Brian") # => "¡Hola Brian!"
  end
end
```
