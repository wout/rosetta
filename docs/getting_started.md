## Installation
**1. Add the dependency to your `shard.yml`:**

```yaml
dependencies:
  rosetta:
    github: wout/rosetta
```

**2. Run `shards install`**

**3. Run `bin/rosetta --init`**

## Using Lucky
Include rosetta in `src/shards.cr`:

```cr
require "rosetta"
```

Use the `integrate` macro in the `config/rosetta.cr` initializer to include
`Rosetta::Translatable` in every base class where translations are needed:

```cr
Rosetta::Lucky.integrate
```

Make sure your tranlations are in place:

```yaml
# config/rosetta/example.en.yml
en:
  hello:
    show_page:
      welcome_message: "Hi %{name}!"
```

Localize your app:

```cr
class Hello::ShowPage < MainLayout
  def content
    h1 r(".welcome_message").t(name: "Jeremy") # => "Hi Jeremy!"
  end
end
```

## Using Kemal
Make sure your tranlations are in place:

```yaml
# config/rosetta/example.en.yml
en:
  welcome_message: "Hi %{name}!"
```

Then `require "config/rosetta"` and `include Rosetta::Translatable`, and you're
good to go:

```cr
require "kemal"
require "../config/rosetta"

include Rosetta::Translatable

get "/" do
  r("welcome_message").t(name: "Serdar") # => "Hi Serdar!"
end
```

## Other frameworks
First `require "config/rosetta.cr"` in your app, and include the
`Rosetta::Translatable` mixin in the base class of controllers, models, views
and anywhere else where you need Rosetta:

```cr
require "config/rosetta.cr"

abstract class BaseController
  include Rosetta::Translatable
end
```

Make sure your tranlations are in place:

```yaml
# config/rosetta/example.en.yml
en:
  hello_controller:
    welcome_message: "Hi %{name}!"
```

Localize your app:

```cr
class HelloController < BaseController
  def index
    puts r(".welcome_message").t(name: "Brian") # => "Hi Brian!"
  end
end
```

