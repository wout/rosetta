module Rosetta
  module Backend
    # Loads the parsed set of locales from the given path. This macro should be
    # called in an initializer:
    #
    # ```
    # Rosetta::Backend.load("config/locales")
    # ```
    macro load(path)
      {%
        if Rosetta.has_constant?("DEFAULT_LOCALE")
          default_locale = Rosetta::DEFAULT_LOCALE
        else
          default_locale = Rosetta::Config::DEFAULT_LOCALE
        end
      %}

      {%
        if Rosetta.has_constant?("AVAILABLE_LOCALES")
          available_locales = Rosetta::AVAILABLE_LOCALES
        else
          available_locales = Rosetta::Config::AVAILABLE_LOCALES
        end
      %}

      TRANSLATIONS = {{
                       run(
                         "./parser",
                         path,
                         default_locale.id,
                         available_locales.join(',').id
                       )
                     }}
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
