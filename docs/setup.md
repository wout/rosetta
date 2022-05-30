# Setup
The `bin/rosetta --init` command will generate the initial files to get started.

**1. An initializer with the following content:**

```cr
# config/rosetta.cr
require "rosetta"

@[Rosetta::DefaultLocale(:en)]
@[Rosetta::AvailableLocales(:en)]
module Rosetta
end

Rosetta::Backend.load("config/rosetta")
```

**2. `config/rosetta/rosetta.en.yml`**

This file contains localizations required by Rosetta. For every additional
locale, you'll need to copy and translate this file.

In the future, files for many languages will be included. Please consider
contributing your translations.

**3. `config/locales/example.en.yml`**

An example locale file, which you can modify or delete.

## For Lucky users
The `bin/rosetta --lucky` command will generate the translations for avram.

**4. `config/locales/avram.en.yml`**

For every additional locale, you'll need to copy and translate this file.
