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

      {%
        translations = run(
          "./runner",
          path,
          default_locale.id,
          available_locales.join(',').id
        )

        if !translations.stringify.starts_with?("module Rosetta")
          raise translations.stringify
        end
      %}

      {{ translations }}
    end
  end
end
