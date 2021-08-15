module Rosetta
  module Backend
    # Loads the parsed set of locales from the given path. This macro should be
    # called in an initializer:
    #
    # ```
    # Rosetta::Backend.load("config/locales")
    # ```
    macro load(path)
      TRANSLATIONS = {{ run("./parser", path) }}
    end

    # Finds the translations hash for a given key at compile-time. If the key
    # could not be found, an error will be raised at compilation.
    macro find(key)
      {%
        translation = TRANSLATIONS[key]

        if translation.is_a?(NilLiteral)
          raise <<-ERROR
          Missing translation for #{key}.
          ERROR
        end
      %}

      {{ translation }}
    end
  end
end
