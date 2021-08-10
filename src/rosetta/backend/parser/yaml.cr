require "yaml"
require "./base"

module Rosetta
  module Backend
    module Parser
      class Yaml < Base
        # Loads all YAML files, parses them and adds them to the store.
        def load : Void
          Dir.glob("#{path}/**/*.yml", "#{path}/**/*.yaml") do |file|
            YAML.parse(File.read(file)).as_h.each do |locale, locale_data|
              add_translations(locale.to_s, locale_data)
            end
          end
        end
      end
    end
  end
end

puts Rosetta::Backend::Parser::Yaml.new(ARGV.first?).parse!
