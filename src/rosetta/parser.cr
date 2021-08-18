require "json"
require "yaml"

module Rosetta
  class Parser
    alias HS2 = Hash(String, String)
    alias TranslationsHash = Hash(String, HS2)

    getter alternative_locales : Array(String)
    getter available_locales : Array(String)
    getter default_locale : String
    getter error : String? = nil
    getter flipped_translations : TranslationsHash? = nil
    getter path : String
    getter ruling_key_set : Array(String)? = nil
    getter translations = TranslationsHash.new

    def initialize(
      @path : String,
      @default_locale : String,
      @available_locales : Array(String)
    )
      @alternative_locales = available_locales - [default_locale]
    end

    # Returns a list of self-containing translation modules
    def parse! : String
      load!

      return error.to_s unless valid?
      return build_wrapper_module([] of String) if translations.empty?

      translation_modules = flipped_translations
        .each_with_object([] of String) do |(key, translations), modules|
          modules << build_module(key, translations)
        end

      build_wrapper_module(translation_modules)
    end

    # Loads and parses JSON files, then YAML files, adds them to the list of
    # translations.
    def load! : Void
      Dir.glob("#{path}/**/*.json") do |file|
        JSON.parse(File.read(file)).as_h.each do |locale, locale_data|
          next unless available_locales.includes?(locale.to_s) && locale_data.as_h?

          add_translations(locale.to_s, locale_data)
        end
      end

      Dir.glob("#{path}/**/*.yml", "#{path}/**/*.yaml") do |file|
        YAML.parse(File.read(file)).as_h.each do |locale, locale_data|
          next unless available_locales.includes?(locale.to_s) && locale_data.as_h?

          add_translations(locale.to_s, locale_data)
        end
      end
    end

    private def build_wrapper_module(translation_modules)
      <<-MODULES
      module Rosetta
        module Locales
          KEYS = [#{ruling_key_set_as_strings}]
      #{translation_modules.join("\n")}
        end
      end
      MODULES
    end

    private def ruling_key_set_as_strings
      return if translations.empty?

      ruling_key_set.map { |k| %("#{k}") }.join(", ")
    end

    private def build_module(key, translations)
      module_name = key.split('.').map(&.camelcase).join("::")
      i12n_keys = translations[default_locale]
        .scan(/%\{([^\}]+)\}/)
        .map { |m| m[1] }

      if i12n_keys.empty?
        methods = <<-METHODS
              def to_s
                raw
              end
        METHODS
      else
        with_arguments = i12n_keys.map { |k| "#{k} : ::String" }.join(", ")
        arguments_tuple = "{#{i12n_keys.map { |k| "#{k}: #{k}" }.join(", ")}}"
        tuple_arguments = i12n_keys.map { |k| "#{k}: ::String" }.join(", ")

        methods = <<-METHODS
              def with(#{with_arguments})
                self.with(#{arguments_tuple})
              end
              def with(values : NamedTuple(#{tuple_arguments}))
                Rosetta.interpolate(raw, values)
              end
              def with_hash(values : ::Hash(::String | ::Symbol, ::String))
                Rosetta.interpolate(raw, values)
              end
              def to_s
                self.with
              end
        METHODS
      end

      <<-MODULE
          module #{module_name}
            extend self
            def raw
              #{translations}[Rosetta.locale]
            end
      #{methods}
          end
      MODULE
    end

    # Tests validity of alternative locale key sets.
    private def valid? : Bool
      return true if available_locales.one?

      check_available_locales_present? &&
        check_key_set_complete? &&
        check_key_set_overflowing? &&
        check_interpolation_keys_matching?

      error.nil?
    end

    # Checks if available locales are present.
    private def check_available_locales_present? : Bool
      return true if (diff = available_locales - translations.keys).empty?

      @error = <<-ERROR
      Expected to find translations for:
      #{pretty_list_for_error(available_locales)}

      But missing all translations for:

      #{pretty_list_for_error(diff)}

      ERROR

      false
    end

    # Checks if all key sets have the same keys as the main locale.
    private def check_key_set_complete? : Bool
      alternative_locales.each do |locale|
        diff = ruling_key_set - translations[locale].keys

        unless diff.empty?
          @error = <<-ERROR
          Missing keys for locale "#{locale}":
          #{pretty_list_for_error(diff)}

          ERROR

          return false
        end
      end

      true
    end

    # Checks if other keys sets don't have more keys than the main locale.
    private def check_key_set_overflowing? : Bool
      alternative_locales.each do |locale|
        diff = translations[locale].keys - ruling_key_set

        unless diff.empty?
          @error = <<-ERROR
          The "#{locale}" locale has unused keys:
          #{pretty_list_for_error(diff)}

          ERROR

          return false
        end
      end

      true
    end

    # Checks if interpolation keys are maching in all available locales.
    private def check_interpolation_keys_matching? : Bool
      errors = ruling_key_set.each_with_object([] of String) do |k, e|
        ruling_translation = flipped_translations[k][default_locale]
        i12n_keys = ruling_translation.scan(/%\{[^\}]+\}/).map { |m| m[0] }

        next if i12n_keys.empty?

        alternative_locales.each do |l|
          i12n_keys.each do |key|
            next if flipped_translations[k][l].index(key)

            e << %(#{l}: #{k} should contain "#{key}")
          end
        end
      end

      unless errors.empty?
        @error = <<-ERROR
        Some translations have mismatching interpolation keys:
        #{pretty_list_for_error(errors)}

        ERROR
      end

      true
    end

    # Returns the key set of the default locale.
    private def ruling_key_set
      @ruling_key_set ||= translations[default_locale].keys
    end

    # Generate a visual list for errors from an array of strings.
    private def pretty_list_for_error(list : Array(String))
      list.map { |key| "  ‣ #{key}\n" }.join
    end

    # Flips translations from top-level locales to top-level keys.
    private def flipped_translations
      @flipped_translations ||= ruling_key_set
        .each_with_object(TranslationsHash.new) do |k, h|
          h[k] = available_locales.each_with_object(HS2.new) do |l, t|
            t[l] = translations[l][k]
          end
        end
    end

    # Adds a set of translations for a given locale to the translations store.
    private def add_translations(locale : String, hash_from_any)
      translations[locale] = HS2.new unless translations[locale]?
      translations[locale].merge!(flatten_hash_from_any(hash_from_any))
    end

    # Flattens a nested hash to a key/value hash.
    private def flatten_hash_from_any(hash)
      hash.as_h.each_with_object(HS2.new) do |(k, v), h|
        if v.as_h?
          flatten_hash_from_any(v).map do |h_k, h_v|
            h["#{k}.#{h_k}"] = h_v
          end
        else
          h[k.to_s] = v.to_s
        end
      end
    end
  end
end
