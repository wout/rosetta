require "spec"
require "../src/rosetta"

Rosetta::DEFAULT_LOCALE = :en
Rosetta::AVAILABLE_LOCALES = %i[en nl]
Rosetta::PLURALIZATION_RULES = {
  "en-pluralization": Rosetta::Pluralization::Rule::OneTwoOther,
  "nl-pluralization": Rosetta::Pluralization::Rule::OneTwoOther,
}

Rosetta::Backend.load("spec/fixtures/rosetta")

def reset_to_default_locale
  Rosetta.locale = Rosetta.default_locale
end
