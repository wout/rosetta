require "spec"
require "../src/rosetta"

@[Rosetta::DefaultLocale(:en)]
@[Rosetta::AvailableLocales(:en, "en-US", :nl)]
@[Rosetta::FallbackRules({
  "en-US": "en",
})]
@[Rosetta::PluralizationRules({
  "en-pluralization": Rosetta::Pluralization::Rule::OneTwoOther,
  "nl-pluralization": Rosetta::Pluralization::Rule::OneTwoOther,
})]
module Rosetta
end

Rosetta::Backend.load("spec/fixtures/rosetta")

def reset_to_default_locale
  Rosetta.locale = Rosetta.default_locale
end
