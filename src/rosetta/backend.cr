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
        anno = Rosetta.annotation(Rosetta::DefaultLocale)
        if anno.nil? || (default_locale = anno.args.first).nil?
          raise <<-ERROR

            No default locale is defined. Add an annotation with exactly one value:

            + @[Rosetta::DefaultLocale(:en)]
              @[Rosetta::AvailableLocales(:en, :fr, :nl)]
              module Rosetta
              end

          ERROR
        end
      %}

      {%
        anno = Rosetta.annotation(Rosetta::AvailableLocales)
        if anno.nil? || (available_locales = anno.args).empty?
          raise <<-ERROR

            No available locales defined. Add an annotation with at least one value:

              @[Rosetta::DefaultLocale(:en)]
            + @[Rosetta::AvailableLocales(:en, :fr, :nl)]
              module Rosetta
              end

          ERROR
        end
      %}

      {%
        fallback_rules = %w[]
        anno = Rosetta.annotation(Rosetta::FallbackRules)
        if anno && (rules = anno.args.first)
          rules.each do |locale, fallback|
            fallback_rules.push("  #{locale.id}: #{fallback.id}")
          end
        end
      %}

      {%
        rules = Rosetta::Pluralization.annotation(
          Rosetta::DefaultPluralizationRules
        ).args.first
        anno = Rosetta.annotation(Rosetta::PluralizationRules)
        if anno && (custom_rules = anno.args.first)
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
          rule = rules[locale] || rules[locale.split("-").first]

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
        fallback_rules:
        #{fallback_rules.join("\n").id}
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
