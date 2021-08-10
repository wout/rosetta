module Rosetta
  module Backend
    module Parser
      abstract class Base
        getter path : String?
        getter translations = {} of String => Hash(String, String)

        def initialize(@path : String?)
        end

        abstract def load : Void

        def parse!
          return if path.nil?

          load

          return "{} of String => Hash(String, String)" if translations.empty?

          "#{translations}"
        end

        private def add_translations(locale : String, hash_from_any)
          translations[locale] = Hash(String, String).new unless translations[locale]?
          translations[locale].merge!(flatten_hash_from_any(hash_from_any))
        end

        private def flatten_hash_from_any(hash)
          hash.as_h.each_with_object({} of String => String) do |(k, v), h|
            if v.as_h?
              flatten_hash_from_any(v).map do |h_k, h_v|
                h["#{k}.#{h_k}"] = h_v.to_s
              end
            else
              h[k.to_s] = v.to_s
            end
          end
        end
      end
    end
  end
end
