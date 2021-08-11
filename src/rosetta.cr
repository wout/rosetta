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

  class_property backends : Hash(String, Hash(String, String)) = Hash(String, Hash(String, String)).new

  def self.init : Void
    @@translator = Translator.new(backends)
  end

  def self.translator
    @@translator.as(Translator)
  end

  delegate self.translate, to: self.translator
  delegate self.t, to: self.translator
end
