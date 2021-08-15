require "json"
require "yaml"

module Rosetta
  class Parser
    alias TranslationsHash = Hash(String, Hash(String, String))

    getter path : String
    getter default_locale : String
    getter available_locales : Array(String)
    getter translations = TranslationsHash.new

    def initialize(
      @path : String,
      @default_locale : String,
      @available_locales : Array(String)
    )
    end

    # Returns a flat list of key/translation pairs as a string.
    def parse! : String?
      load!

      return "{} of String => Hash(String, String)" if translations.empty?

      "#{flip(translations)}"
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

    # Flips translations from top-level locales to top-level keys.
    private def flip(translations)
      locales = translations.keys
      ruling_key_set = translations[default_locale].keys

      ruling_key_set.each_with_object(TranslationsHash.new) do |k, h|
        h[k] = locales.each_with_object({} of String => String) do |l, t|
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
