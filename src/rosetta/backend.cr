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
        yaml = <<-YAML
        path: #{path}
        default_locale: #{default_locale.id}
        available_locales: [#{available_locales.join(',').id}]
        pluralization_rules:
          en: Rosetta::Pluralization::Rule::OneOther
          nl: Rosetta::Pluralization::Rule::OneOther
        pluralization_tags:
          Rosetta::Pluralization::Rule::OneOther: [one, other]
        YAML
      %}

      {%
        translations = run("./runner", yaml)

        if !translations.stringify.starts_with?("module Rosetta")
          raise translations.stringify
        end
      %}

      {{ translations }}
    end
  end
end
