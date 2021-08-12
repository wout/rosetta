require "json"
require "yaml"
require "habitat"

require "./rosetta/**"

module Rosetta
  Habitat.create do
    setting default_locale : String = "en",
      example: %("en" or "en-GB")
    setting available_locales : Array(String) = %w[en],
      example: "%w[en fr] or %w[de en-GB en-US es nl]"
    setting fallbacks : Fallbacks
  end

  macro look_up(key)
    Rosetta::Backend.look_up({{key}})
  end

  def self.locale=(locale : String)
    @@locale = if settings.available_locales.includes?(locale)
                 locale
               else
                 # TODO: make use of a fallback here
                 settings.default_locale
               end
  end

  def self.locale : String
    @@locale || settings.default_locale
  end
end
