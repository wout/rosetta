module Rosetta
  class Builder
    getter default_locale

    def initialize(@default_locale : String)
    end

    # Builds the wrapping module for all translation structs.
    def build_locales(translations : TranslationsHash)
      <<-MODULE
      module Rosetta
        module Locales
      #{build_structs(translations).join("\n")}
        end
      end
      MODULE
    end

    # Builds a translation struct for every single translation key.
    private def build_structs(translations : TranslationsHash)
      translations.each_with_object([] of String) do |(k, t), s|
        s << build_struct(k, t)
      end
    end

    # Builds a dedicated struct for a given translation key.
    private def build_struct(
      key : String,
      translations : Translations
    )
      class_name = key.split('.').map(&.camelcase).join('_')

      <<-CLASS
          struct #{class_name}Translation < Rosetta::Translation
            getter translations = #{build_translations_tuple(translations)}
      #{build_struct_methods(key, translations)}
          end
      CLASS
    end

    # Builds the struct methods for the given interpolation and localization
    # keys.
    private def build_struct_methods(
      key : String,
      translations : Translations
    )
      i12n_keys = translations[default_locale].to_s
        .scan(/%\{([^\}]+)\}/)
        .map(&.[1])
        .uniq!
        .sort
      l10n_keys = translations[default_locale].to_s
        .scan(/%(\^?[a-z])/i)
        .map(&.[1])

      if i12n_keys.empty? && l10n_keys.empty?
        return <<-METHODS
              include Rosetta::SimpleTranslation
        METHODS
      end

      args = i12n_keys.map { |k| [k, (k == "count" ? "Float | Int" : "String")] }
      args << ["time", "Time"] unless l10n_keys.empty?
      with_args = args.map(&.join(" : ")).join(", ")

      <<-METHODS
            include Rosetta::#{build_inclusion_module(translations)}Translation
            def t(#{with_args})
              #{build_translation_return_value(translations, l10n_keys)}
            end
            def t(values : NamedTuple(#{args.map(&.join(": ")).join(", ")}))
              self.t(**values)
            end
            def to_s(io)
              {% raise %(Rosetta.find("#{key}") expected to receive t(#{with_args}) but to_s was called instead) %}
            end
      METHODS
    end

    # Build a translation type module based on the content of the translations
    # opbject.
    private def build_inclusion_module(translations : Translations)
      pluralizable?(translations) ? "Pluralized" : "Interpolated"
    end

    # Builds a tuple with translation values.
    private def build_translations_tuple(translations : Translations)
      pairs = translations.each_with_object([] of String) do |(k, t), s|
        case t
        when String
          s << %(#{k}: "#{t}")
        when Hash
          s << %(#{k}: #{build_translations_tuple(t)})
        end
      end

      "{#{pairs.join(", ")}}"
    end

    # Builds a translation return value and localize it if required.
    private def build_translation_return_value(
      translations : Translations,
      l10n_keys : Array(String)
    )
      parsed_tuple = build_translations_tuple(translations).gsub(/\%\{/, "\#{")
      value = "#{parsed_tuple}[Rosetta.locale]"
      value = "Rosetta.pluralize(count, #{value})" if pluralizable?(translations)
      value = "Rosetta.localize_time(time, #{value})" unless l10n_keys.empty?

      value
    end

    # Test if contents of a translation are pluralizable.
    private def pluralizable?(translations : Translations) : Bool
      translations.first[1].is_a?(Hash)
    end
  end
end
