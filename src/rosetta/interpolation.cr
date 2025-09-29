module Rosetta
  # Interpolates a given string with the values from the given hash or named
  # tuple.
  def self.interpolate(
    translation : String,
    values : Hash | NamedTuple,
  )
    values.each do |key, value|
      translation = if value.is_a?(Time)
                      localize_time(value, translation)
                    elsif value.is_a?(Tuple(Int32, Int32, Int32))
                      localize_time(Time.local(*value), translation)
                    else
                      translation.gsub(/\%\{#{key}\}/, value)
                    end
    end

    translation
  end

  class InterpolationArgumentException < Exception; end
end
