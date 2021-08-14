require "json"
require "yaml"

require "./rosetta/**"

module Rosetta
  # Finds translations for the given key. The returned object contains
  # translations for every configured locale:
  #
  # ```
  # Rosetta.find("user.name")
  # # => { "en" => "Name", "es" => "Nombre", "nl" => "Naam" }
  # ```
  # If the key does not exist, a compile error will be raised.
  macro find(key)
    Rosetta::Backend.find({{key}})
  end

  # Translates a given hash with translations, typically returned by the `find`
  # macro, using the currently configured locale. If interpolation values are
  # given, the string is interpolated using those values.
  def self.t(
    translation : Hash(String, String),
    interpolation_values : Hash(String | Symbol, String) | NamedTuple
  ) : String
    interpolate(translation[locale], interpolation_values)
  end

  # Alternative translation method with named arguments for the interpolation
  # values
  def self.t(
    translation : Hash(String, String),
    **interpolation_values
  ) : String
    t(translation, interpolation_values)
  end
end
