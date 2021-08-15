module Rosetta
  # Interpolates a given string with tha values from the given hash or named
  # tuple.
  def self.interpolate(
    translation : String,
    values : Hash(String | Symbol, String) | NamedTuple
  )
    values.each do |key, value|
      translation = translation.gsub(/\%{#{key}}/, value)
    end

    translation
  end
end
