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

    # Build a dedicated struct for a given translation key.
    private def build_struct(
      key : String,
      translation : Translations
    )
      class_name = key.split('.').map(&.camelcase).join('_')

      <<-CLASS
          struct #{class_name}Translation < Rosetta::Translation
            getter translations = #{translation}
      #{build_struct_methods(key, translation)}
          end
      CLASS
    end

    # Build the struct methods for the given interpolation and localization
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
      args_tuple = args.map { |k| "#{k[0]}: #{k[0]}" }.join(", ")
      with_args = args.map(&.join(" : ")).join(", ")

      <<-METHODS
            def t
              raise <<-ERROR
              Missing interpolation values, use the "with" method:

                Rosetta.find("#{key}").t(#{with_args})
              ERROR
            end
            def t(#{with_args})
              Rosetta.interpolate(raw, {#{args_tuple}})
            end
            def t(values : NamedTuple(#{args.map(&.join(": ")).join(", ")}))
              self.t(**values)
            end
      METHODS
    end
  end
end
