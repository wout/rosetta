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
        pluralization_rules = [] of String
        pluralization_tags = [] of String
        rules = Rosetta::Pluralization.constant("RULES")

        if Rosetta.has_constant?("PLURALIZATION_RULES")
          Rosetta::PLURALIZATION_RULES.each do |locale, rule|
            rules[locale] = rule
          end
        end

        available_locales.each do |locale|
          rule = rules[locale]

          raise %(No pluralization rule is defined for "#{locale.id}") unless rule

          rule = rule.resolve
          anno = rule.annotation(Rosetta::Pluralization::CategoryTags)

          if anno
            pluralization_tags.push("  #{rule}: [#{anno.args.join(',').id}]")
          else
            raise "#{rule} is missing a CategoryTags annotation"
          end

          pluralization_rules.push("  #{locale.id}: #{rule}")
        end
      %}

      {%
        yaml = <<-YAML
        path: #{path.id}
        default_locale: #{default_locale.id}
        available_locales: [#{available_locales.join(',').id}]
        pluralization_rules:
        #{pluralization_rules.join("\n").id}
        pluralization_tags:
        #{pluralization_tags.uniq.join("\n").id}
        YAML

        translations = run("./runner", yaml)

        if !translations.stringify.starts_with?("module Rosetta")
          raise translations.stringify
        end
      %}

      {{ translations }}
    end
  end
end
