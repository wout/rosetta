require "spec"
require "../src/rosetta"

Rosetta.backends << Rosetta::Backend::Yaml.load("spec/fixtures/locales")
