require "json"
require "yaml"

module Rosetta
  class Parser
    alias TranslationsHash = Hash(String, Hash(String, String))

    getter path : String
    getter default_locale : String
    getter available_locales : Array(String)
    getter alternative_locales : Array(String)
    getter translations = TranslationsHash.new
    getter error : String? = nil

    def initialize(
      @path : String,
      @default_locale : String,
      @available_locales : Array(String)
    )
      @alternative_locales = available_locales - [default_locale]
    end

    # Returns a flat list of key/translation pairs as a string.
    def parse! : String
      load!

      return error.to_s unless valid?

      return "{} of String => Hash(String, String)" if translations.empty?

      "#{flip(translations)}"
    end

    # Tests validity of all locale key sets.
    def valid? : Bool
      check_available_locales_present? &&
        check_key_set_complete? &&
        check_key_set_overflowing? &&
        check_interpolation_keys_matching?

      error.nil?
    end

    # Loads and parses JSON files, then YAML files, adds them to the list of
    # translations.
    def load! : Void
      Dir.glob("#{path}/**/*.json") do |file|
        JSON.parse(File.read(file)).as_h.each do |locale, locale_data|
          next unless available_locales.includes?(locale.to_s)

          add_translations(locale.to_s, locale_data)
        end
      end

      Dir.glob("#{path}/**/*.yml", "#{path}/**/*.yaml") do |file|
        YAML.parse(File.read(file)).as_h.each do |locale, locale_data|
          next unless available_locales.includes?(locale.to_s)

          add_translations(locale.to_s, locale_data)
        end
      end
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
      true
    end

    # Returns the key set of the default locale.
    private def ruling_key_set
      translations[default_locale].keys
    end

    # Generate a visual list for errors from an array of strings.
    private def pretty_list_for_error(list : Array(String))
      list.map { |key| "  ‣ #{key}\n" }.join
    end

    # Flips translations from top-level locales to top-level keys.
    private def flip(translations)
      ruling_key_set.each_with_object(TranslationsHash.new) do |k, h|
        h[k] = available_locales.each_with_object({} of String => String) do |l, t|
          t[l] = translations[l][k]
        end
      end
    end

    # Adds a set of translations for a given locale to the translations store.
    private def add_translations(locale : String, hash_from_any)
      translations[locale] = {} of String => String unless translations[locale]?
      translations[locale].merge!(flatten_hash_from_any(hash_from_any))
    end

    # Flattens a nested hash to a key/value hash.
    private def flatten_hash_from_any(hash)
      hash.as_h.each_with_object({} of String => String) do |(k, v), h|
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

if !ARGV.empty? && ARGV[0] == "rosetta" && ARGV.size == 4
  puts Rosetta::Parser.new(
    path: ARGV[1].to_s,
    default_locale: ARGV[2].to_s,
    available_locales: ARGV[3].to_s.split(',')
  ).parse!
end
