require "json"
require "yaml"
require "./parser/builder"

module Rosetta
  alias Translations = Hash(String, Hash(String, String) | String)
  alias TranslationsHash = Hash(String, Translations)

  class Parser
    getter alternative_locales : Array(String)
    getter available_locales : Array(String)
    getter default_locale : String
    getter error : String? = nil
    getter path : String
    getter ruling_key_set : Array(String)
    getter translations : TranslationsHash

    @processed_translations : TranslationsHash? = nil

    def initialize(
      @path : String,
      default_locale : String | Symbol,
      available_locales : Array(String | Symbol)
    )
      @default_locale = default_locale.to_s
      @available_locales = available_locales.map(&.to_s)
      @alternative_locales = @available_locales - [@default_locale]
      @translations = load_translations
      @ruling_key_set = collect_ruling_keys(@translations, @default_locale)
    end

    # Returns a list of self-containing translation modules.
    def parse! : String
      builder = Builder.new(default_locale)

      return builder.build_locales(translations) if translations.empty?
      return error.to_s unless valid_key_set?

      builder.build_locales(processed_translations)
    end

    # Tests validity of alternative locale key sets.
    private def valid_key_set? : Bool
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
        ruling_translation = processed_translations[k][default_locale]
        i12n_keys = ruling_translation.to_s.scan(/%\{[^\}]+\}/).map { |m| m[0] }

        next if i12n_keys.empty?

        alternative_locales.each do |l|
          i12n_keys.each do |key|
            next if processed_translations[k][l].to_s.match(%r{#{key}})

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
    private def collect_ruling_keys(
      translations : TranslationsHash,
      default_locale : String
    )
      return %w[] if translations.empty?

      translations[default_locale].keys
    end

    # Generate a visual list for errors from an array of strings.
    private def pretty_list_for_error(list : Array(String))
      list.map { |key| "  ‣ #{key}\n" }.join
    end

    # Flips translations from top-level locales to top-level keys.
    private def processed_translations
      @processed_translations ||= ruling_key_set
        .each_with_object(TranslationsHash.new) do |k, h|
          h[k] = available_locales.each_with_object(Translations.new) do |l, t|
            t[l] = translations[l][k]
          end
        end
    end

    # Loads and parses JSON files, then YAML files, merges them together and
    # returns the merged list.
    private def load_translations : TranslationsHash
      TranslationsHash.new.tap do |translations|
        Dir.glob("#{path}/**/*.json") do |file|
          JSON.parse(File.read(file)).as_h.each do |locale, locale_data|
            next unless available_locales.includes?(locale.to_s) &&
                        locale_data.as_h?

            add_translations(translations, locale.to_s, locale_data)
          end
        end

        Dir.glob("#{path}/**/*.yml", "#{path}/**/*.yaml") do |file|
          YAML.parse(File.read(file)).as_h.each do |locale, locale_data|
            next unless available_locales.includes?(locale.to_s) &&
                        locale_data.as_h?

            add_translations(translations, locale.to_s, locale_data)
          end
        end
      end
    end

    # Adds a set of translations for a given locale to the translations store.
    private def add_translations(
      translations : TranslationsHash,
      locale : String,
      hash_from_any
    ) : TranslationsHash
      translations[locale] = Translations.new unless translations[locale]?
      translations[locale].merge!(flatten_hash_from_any(hash_from_any))
      translations
    end

    # Flattens a nested hash to a key/value hash.
    private def flatten_hash_from_any(hash)
      hash.as_h.each_with_object(Translations.new) do |(k, v), h|
        case v
        when .as_h?
          if pluralizable_hash?(v.as_h)
            h[k.to_s] = v.as_h.transform_keys(&.to_s)
              .transform_values(&.to_s)
          else
            flatten_hash_from_any(v).map do |h_k, h_v|
              h["#{k}.#{h_k}"] = h_v
            end
          end
        else
          h[k.to_s] = v.to_s
        end
      end
    end

    # Test if contents of a translation are pluralizable
    private def pluralizable_hash?(hash : Hash)
      hash["other"]? && hash["other"].to_s.match(/%\{count\}/)
    end
  end
end
