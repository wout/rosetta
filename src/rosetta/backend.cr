module Rosetta
  module Backend
    # Loads the parsed set of locales from the given path. This macro should be
    # called in an initializer:
    #
    # ```
    # Rosetta::Backend.load("config/locales")
    # ```
    macro load(path)
      # REMOVE THIS AT THE RELEASE OF VERSION 1.0.0
      {%
        if Rosetta.has_constant?("AVAILABLE_LOCALES") ||
          Rosetta.has_constant?("DEFAULT_LOCALE") ||
          Rosetta.has_constant?("PLURALIZATION_RULES")
          raise <<-ERROR

            The Rosetta::DEFAULT_LOCALE, Rosetta::AVAILABLE_LOCALES and
            Rosetta::PLURALIZATION_RULES constants are no longer considered.
            
            Use an annotation instead, for example:

              @[Rosetta::DefaultLocale(:en)]
              @[Rosetta::AvailableLocales(:en, :fr, :nl)]
              @[Rosetta::PluralizationRules({
                en: Rosetta::Pluralization::Rule::OneTwoOther,
                fr: Rosetta::Pluralization::Rule::OneTwoOther,
                nl: Rosetta::Pluralization::Rule::OneTwoOther,
              })]
              module Rosetta
              end
          
          ERROR
        end
      %}

      {%
        default_locale = Rosetta.annotation(Rosetta::DefaultLocale).args.first
        if default_locale.nil?
          raise <<-ERROR

            No default locale is defined. Add an annotation with exactly one value:
              
              @[Rosetta::DefaultLocale(:en)]
              @[Rosetta::AvailableLocales(:en, :fr, :nl)]
              module Rosetta
              end
          
          ERROR
        end
      %}

      {% 
        available_locales = Rosetta.annotation(Rosetta::AvailableLocales).args
        if available_locales.empty?
          raise <<-ERROR

            No available locales defined. Add an annotation with at least one value:
              
              @[Rosetta::AvailableLocales(:en, :fr, :nl)]
              module Rosetta
              end
          
          ERROR
        end
      %}

      {%
        rules = Rosetta::Pluralization.annotation(
          Rosetta::DefaultPluralizationRules
        ).args.first
        
        if custom_rules = Rosetta.annotation(Rosetta::PluralizationRules).args.first
          custom_rules.each do |locale, rule|
            rules[locale] = rule
          end
        end
      %}

      Rosetta::Pluralization::RULES = {{rules}}

      {%
        pluralization_rules = [] of String
        pluralization_tags = [] of String

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
