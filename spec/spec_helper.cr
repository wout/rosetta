require "spec"
require "../src/rosetta"

module Rosetta
  DEFAULT_LOCALE    = "en"
  AVAILABLE_LOCALES = %w[en nl]
end

Rosetta::Backend.load("spec/fixtures/locales")

def reset_to_default_locale
  Rosetta.locale = Rosetta.default_locale
end
