module Rosetta
  class Builder
    getter default_locale

    def initialize(@default_locale : String)
    end

    # Build the wrapping module including the KEYS constant containing an array
    # of all included translation keys.
    def build_locales(translations : TranslationsHash)
      <<-MODULE
      module Rosetta
        module Locales
          KEYS = %w[#{translations.keys.join(' ')}]
      #{build_classes(translations).join("\n")}
        end
      end
      MODULE
    end

    # Build a translation class for every single key.
    private def build_classes(translations : TranslationsHash)
      translations.each_with_object([] of String) do |(key, translation), classes|
        classes << build_class(key, translation)
      end
    end

    # Build a dedicated class for a given translation key.
    private def build_class(
      key : String,
      translation : Translations
    )
      class_name = key.split('.').map(&.camelcase).join("::")

      <<-CLASS
          class #{class_name}Translation < Rosetta::Translation
            getter translations = #{translation}
      #{build_class_methods(key, translation)}
          end
      CLASS
    end

    # Build the class methods for the given interpolation and localization keys.
    private def build_class_methods(
      key : String,
      translation : Translations
    )
      i12n_keys = translation[default_locale].to_s.scan(/%\{([^\}]+)\}/).map(&.[1])
      l10n_keys = translation[default_locale].to_s.scan(/%(\^?[a-z])/i).map(&.[1])

      if i12n_keys.empty? && l10n_keys.empty?
        return <<-METHODS
              def to_s
                raw
              end
              def with
                raw
              end
        METHODS
      end

      args = i12n_keys.map { |k| [k, "String"] }
      args << ["time", "Time"] unless l10n_keys.empty?
      args_tuple = args.map { |k| "#{k[0]}: #{k[0]}" }.join(", ")

      <<-METHODS
            def with(#{args.map(&.join(" : ")).join(", ")})
              Rosetta.interpolate(raw, {#{args_tuple}})
            end
            def with(values : NamedTuple(#{args.map(&.join(": ")).join(", ")}))
              self.with(**values)
            end
      METHODS
    end
  end
end
