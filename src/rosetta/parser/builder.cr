module Rosetta
  class Builder
    getter default_locale

    def initialize(@default_locale : String)
    end

    # Builds the wrapping module including the KEYS constant containing an array
    # of all included translation keys.
    def build_locales(translations : TranslationsHash)
      <<-MODULE
      module Rosetta
        module Locales
          KEYS = %w[#{translations.keys.join(' ')}]
      #{build_structs(translations).join("\n")}
        end
      end
      MODULE
    end

    # Build a translation struct for every single key.
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
      translation : Translations
    )
      i12n_keys = translation[default_locale].to_s.scan(/%\{([^\}]+)\}/).map(&.[1])
      l10n_keys = translation[default_locale].to_s.scan(/%(\^?[a-z])/i).map(&.[1])

      if i12n_keys.empty? && l10n_keys.empty?
        return <<-METHODS
              def t
                raw
              end
        METHODS
      end

      args = i12n_keys.map { |k| [k, "String"] }
      args << ["time", "Time"] unless l10n_keys.empty?
      with_args = args.map(&.join(" : ")).join(", ")

      <<-METHODS
            def t
              raise <<-ERROR
              Missing interpolation values, use the "with" method:

                Rosetta.find("#{key}").t(#{with_args})
              ERROR
            end
            def t(#{with_args})
              #{build_translation_return_value(translation, l10n_keys)}
            end
            def t(values : NamedTuple(#{args.map(&.join(": ")).join(", ")}))
              self.t(**values)
            end
      METHODS
    end

    # Builds a tuple with translation values.
    private def build_translations_tuple(translations : Translations)
      pairs = translations.each_with_object([] of String) do |(k, t), s|
        s << %(#{k}: "#{t}")
      end

      "{#{pairs.join(", ")}}"
    end

    # Builds a translation return value and localize it if required.
    private def build_translation_return_value(
      translations : Translations,
      l10n_keys : Array(String)
    )
      parsed_tuple = build_translations_tuple(translations).gsub(/\%\{/, "\#{")

      if l10n_keys.empty?
        "#{parsed_tuple}[Rosetta.locale]"
      else
        "Rosetta.localize(#{parsed_tuple}[Rosetta.locale], time)"
      end
    end
  end
end
