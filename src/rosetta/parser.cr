require "json"
require "yaml"
require "./parser/builder"
require "./parser/checks"
require "./parser/config"

module Rosetta
  alias Translations = Hash(String, Hash(String, String) | String)
  alias TranslationsHash = Hash(String, Translations)

  NESTED_KEY_REGEX = /%r\{\s*([^}]+)\s*\}/

  class Parser
    include Checks

    delegate available_locales, to: config
    delegate default_locale, to: config
    delegate fallback_rules, to: config
    delegate path, to: config

    getter alternative_locales : Array(String)
    getter config : Config
    getter error : String? = nil
    getter pluralization_tags : Hash(String, Array(String))
    getter ruling_key_set : Array(String)
    getter translations : TranslationsHash

    @processed_translations : TranslationsHash? = nil

    def initialize(@config : Config)
      @alternative_locales = available_locales - [default_locale]
      @translations = resolve_nested_keys(ensure_fallbacks(load_translations))
      @ruling_key_set = collect_ruling_keys(@translations, default_locale)
      @pluralization_tags = map_locales_to_pluralization_tags(
        config.pluralization_rules,
        config.pluralization_tags
      )
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
        check_nested_keys_present? &&
        check_key_set_complete? &&
        check_key_set_overflowing? &&
        check_interpolation_keys_matching? &&
        check_pluralization_tags_complete? &&
        check_variant_keys_matching?

      error.nil?
    end

    # Returns the key set of the default locale.
    private def collect_ruling_keys(
      translations : TranslationsHash,
      default_locale : String,
    )
      return %w[] if translations.empty?

      translations[default_locale].keys
    end

    # Map locales to pluralization category tags.
    private def map_locales_to_pluralization_tags(
      rules : Hash(String, String),
      tags : Hash(String, Array(String)),
    )
      rules.each_with_object({} of String => Array(String)) do |(locale, rule), hash|
        hash[locale] = tags[rule]
      end
    end

    # Generate a visual list for errors from an array of strings.
    private def pretty_list_for_error(list : Array(String))
      list.map { |key| "  ‣ #{key}\n" }.join
    end

    # Flips translations from top-level locales to top-level keys.
    private def processed_translations
      @processed_translations ||= ruling_key_set
        .each_with_object(TranslationsHash.new) do |key, hash|
          hash[key] = available_locales.each_with_object(Translations.new) do |locale, trans|
            trans[locale] = translations[locale][key]
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
      hash_from_any,
    ) : TranslationsHash
      translations[locale] = Translations.new unless translations[locale]?
      translations[locale].merge!(flatten_hash_from_any(hash_from_any))
      translations
    end

    # Flattens a nested hash to a key/value hash.
    private def flatten_hash_from_any(hash)
      hash.as_h.each_with_object(Translations.new) do |(key, value), flat_hash|
        case value
        when .as_h?
          if pluralizable_hash?(value.as_h) || variants_key?(key.to_s)
            flat_hash[key.to_s] = value.as_h.transform_keys(&.to_s)
              .transform_values(&.to_s)
          else
            flatten_hash_from_any(value).map do |h_k, h_v|
              flat_hash["#{key}.#{h_k}"] = h_v
            end
          end
        else
          flat_hash[key.to_s] = value.to_s
        end
      end
    end

    # Apply fallback rules
    private def ensure_fallbacks(hash : TranslationsHash)
      if rules = fallback_rules
        rules.each do |target, fallback|
          next unless hash[fallback]?
          hash[target] = hash[fallback]
            .merge(hash[target]? || {} of String => String)
        end
      end

      hash
    end

    # Resolves nested keys one level deep
    private def resolve_nested_keys(hash : TranslationsHash)
      hash.each do |locale, translations|
        translations.each do |key, value|
          next unless value.is_a?(String)
          next unless value.includes?("%r{")
          next unless m = value.match(NESTED_KEY_REGEX)
          next unless resolved = translations[m[1]]?

          hash[locale][key] = value.gsub(m[0], resolved)
        end
      end

      hash
    end

    # Test if the key matches the variants convention.
    private def variants_key?(key : String)
      key.match(/.+_variants$/)
    end

    # Test if contents of a translation are pluralizable.
    private def pluralizable_hash?(hash : Hash)
      hash["other"]? && hash["other"].to_s.match(/%\{count\}/)
    end

    private def pluralizable_hash?(string : String)
      false
    end
  end
end
