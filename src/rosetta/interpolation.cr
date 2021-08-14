module Rosetta
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
