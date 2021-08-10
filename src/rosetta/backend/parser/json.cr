require "json"
require "./base"

module Rosetta
  module Backend
    module Parser
      class Json < Base
        # Loads all JSON files, parses them and adds them to the store.
        def load : Void
          Dir.glob("#{path}/**/*.json") do |file|
            JSON.parse(File.read(file)).as_h.each do |locale, locale_data|
              add_translations(locale.to_s, locale_data)
            end
          end
        end
      end
    end
  end
end

puts Rosetta::Backend::Parser::Json.new(ARGV.first?).parse!
