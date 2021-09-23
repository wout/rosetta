require "json"
require "yaml"
require "./parser/builder"
require "./parser/checks"
require "./parser/config"

module Rosetta
  alias Translations = Hash(String, Hash(String, String) | String)
  alias TranslationsHash = Hash(String, Translations)

  class Parser
    include Checks

    delegate path, to: config
    delegate default_locale, to: config
    delegate available_locales, to: config

    getter alternative_locales : Array(String)
    getter error : String? = nil
    getter ruling_key_set : Array(String)
    getter translations : TranslationsHash
    getter config : Config

    @processed_translations : TranslationsHash? = nil

    def initialize(@config : Config)
      @alternative_locales = available_locales - [default_locale]
      @translations = load_translations
      @ruling_key_set = collect_ruling_keys(@translations, default_locale)
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

    # Test if contents of a translation are pluralizable.
    private def pluralizable_hash?(hash : Hash) : Bool
      !!hash["other"]? && !!hash["other"].to_s.match(/%\{count\}/)
    end
  end
end
