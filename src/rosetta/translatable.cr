module Rosetta
  # Include this module anywhere translations need to be added
  module Translatable
    # Looks up and returns the translation for the given key. If the given key
    # starts with a ".", a prefix based on the current class name will be used.
    # Unless the constant ROSETTA_PREFIX is defined, which will then be used
    # instead.
    macro rosetta(key)
      {%
        if key.starts_with?('.')
          if @type.has_constant?("ROSETTA_PREFIX")
            key = "#{ROSETTA_PREFIX.id}#{key.id}"
          else
            key = "#{@type.id.underscore.gsub(/::/, ".").id}#{key.id}"
          end
        end
      %}

      Rosetta.find({{key}})
    end

    # Returns the translation for the currently selected locale and accepts
    # interpolation values as a has or named tuple.
    def t(
      translation : Hash(String, String),
      interpolation_values : Hash(String | Symbol, String) | NamedTuple
    ) : String
      Rosetta.t(translation, interpolation_values)
    end

    # Alternative translation method with named arguments for the interpolation
    # values.
    def t(
      translation : Hash(String, String),
      **interpolation_values
    ) : String
      Rosetta.t(translation, interpolation_values)
    end
  end
end
