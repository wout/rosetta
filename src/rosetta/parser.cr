require "json"
require "yaml"

module Rosetta
  class Parser
    alias TranslationsHash = Hash(String, Hash(String, String))

    getter path : String
    # getter default_locale : String
    # getter available_locales : Array(String)
    getter translations = TranslationsHash.new

    def initialize(
      @path : String
    )
    end

    # Loads and parses JSON files, then YAML files and adds them to the list of
    # translations.
    def load : Void
      Dir.glob("#{path}/**/*.json") do |file|
        JSON.parse(File.read(file)).as_h.each do |locale, locale_data|
          add_translations(locale.to_s, locale_data)
        end
      end

      Dir.glob("#{path}/**/*.yml", "#{path}/**/*.yaml") do |file|
        YAML.parse(File.read(file)).as_h.each do |locale, locale_data|
          add_translations(locale.to_s, locale_data)
        end
      end
    end

    def parse! : String?
      return if path.nil?

      load

      return "{} of String => Hash(String, String)" if translations.empty?

      "#{flip(translations)}"
    end

    private def flip(translations)
      locales = translations.keys

      # TODO: pass primary language as ARGV to use as the bas set of keys
      translations["en"].keys.each_with_object(TranslationsHash.new) do |k, h|
        h[k] = locales.each_with_object({} of String => String) do |l, t|
          t[l] = translations[l][k]
        end
      end
    end

    private def add_translations(locale : String, hash_from_any)
      translations[locale] = {} of String => String unless translations[locale]?
      translations[locale].merge!(flatten_hash_from_any(hash_from_any))
    end

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

unless ARGV.empty?
  puts Rosetta::Parser.new(
    path: ARGV[0].to_s
  ).parse!
end
