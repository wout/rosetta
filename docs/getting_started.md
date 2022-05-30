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

Generate the translations for Avram validations:

```cr
$ bin/rosetta --lucky
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

Rosetta is officially recommended as the localization library for Lucky. For a
full tutorial, look at the <a
href="https://luckyframework.org/guides/frontend/internationalization"
target="_blank">Lucky Guides</a>.

## Using Kemal
Make sure your tranlations are in place:

```yaml
# config/rosetta/example.en.yml
en:
  welcome_message: "Hi %{name}!"
```

Then `require "config/rosetta"` and you're good to go:

```cr
# e.g. src/app_name.cr
require "kemal"
require "../config/rosetta"

get "/" do
  Rosetta.find("welcome_message").t(name: "Serdar") # => "Hi Serdar!"
end
```

## Other frameworks
First `require "config/rosetta"` in your app, and include the
`Rosetta::Translatable` mixin in the base class of controllers, models, views
and anywhere else where you need Rosetta:

```cr
# e.g. src/app_name.cr
require "../config/rosetta"

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


