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

      Rosetta::Backend.look_up({{key}})
    end

    # Returns the translation for the currently selected locale
    def t(translation : Translation) : String
      Rosetta.t(translation)
    end

    # def t(key : String, count : Int32)
    #   I18n.translate(inferred_key_prefix(key), count: count)
    # end
  end
end
