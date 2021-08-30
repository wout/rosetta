module Rosetta
  # Interpolates a given string with the values from the given hash or named
  # tuple.
  def self.interpolate(
    translation : String,
    values : Hash(String | Symbol, String | Time) | NamedTuple
  )
    values.each do |key, value|
      translation = if value.is_a?(Time)
                      localize(translation, value)
                    else
                      translation.gsub(/\%{#{key}}/, value)
                    end
    end

    translation
  end
end
