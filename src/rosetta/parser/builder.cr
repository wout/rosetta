module Rosetta
  class Parser
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
        stringified = translations[default_locale].to_s
        i12n_keys = stringified.scan(/%\{([^\}]+)\}/).map(&.[1]).uniq!.sort
        l10n_keys = stringified.scan(/%(\^?[a-z])/i).map(&.[1])

        if i12n_keys.empty? && l10n_keys.empty? && !variants_key?(key)
          return <<-METHODS
                include Rosetta::SimpleTranslation
          METHODS
        end

        args = i12n_keys.map { |k| [k, (k == "count" ? "Rosetta::CountArg" : "String")] }
        args << ["time", "Time | Tuple(Int32, Int32, Int32)"] unless l10n_keys.empty?
        args << ["variant", "String"] if variants_key?(key)
        with_args = args.map(&.join(" : ")).join(", ")
        named_tuple_keys = args.map(&.join(": ")).join(", ")
        inclusion_module = build_inclusion_module(key, translations)
        translation_return_value = build_translation_return_value(
          key, translations, i12n_keys, l10n_keys
        )

        <<-METHODS
              include #{inclusion_module}
              def t(#{with_args})
                #{translation_return_value}
              end
              def t(values : NamedTuple(#{named_tuple_keys}))
                self.t(**values)
              end
              def to_s(io)
                {% raise %(Rosetta.find("#{key}") expected to receive t(#{with_args}) but to_s was called instead) %}
              end
        METHODS
      end

      # Build a translation type module based on the key or content of the
      # translations object.
      private def build_inclusion_module(
        key : String,
        translations : Translations
      )
        module_name = if variants_key?(key)
                        "Variants"
                      elsif pluralizable?(translations)
                        "Pluralized"
                      else
                        "Interpolated"
                      end

        "Rosetta::#{module_name}Translation"
      end

      # Builds a tuple with translation values.
      private def build_translations_tuple(translations : Translations)
        pairs = translations.each_with_object([] of String) do |(k, t), s|
          case t
          when String
            s << %(#{k}: %(#{t}))
          when Hash
            s << %(#{k}: #{build_translations_tuple(t)})
          end
        end

        "{#{pairs.join(", ")}}"
      end

      # Builds a translation return value and localize it if required.
      private def build_translation_return_value(
        key : String,
        translations : Translations,
        i12n_keys : Array(String),
        l10n_keys : Array(String)
      )
        parsed_tuple = if i12n_keys.empty?
                         "translations"
                       else
                         build_translations_tuple(translations).gsub(/\%\{/, "\#{")
                       end
        value = "#{parsed_tuple}[Rosetta.locale]"

        if variants_key?(key)
          value = "#{value}[variant]"
        elsif pluralizable?(translations)
          value = "Rosetta.pluralize(count, #{value})"
        end

        value = "Rosetta.localize_time(time, #{value})" unless l10n_keys.empty?

        value
      end

      # Test if the key matches the variants convention.
      private def variants_key?(key : String) : Bool
        !!key.match(/.+_variants$/)
      end

      # Test if contents of a translation are pluralizable.
      private def pluralizable?(translations : Translations) : Bool
        translations.first[1].is_a?(Hash) && !!translations.first[1]["other"]?
      end
    end
  end
end
