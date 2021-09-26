module Rosetta
  # Include this module in any class where you need to translate many keys.
  module Translatable
    # Finds the translation for the given key. If the given key starts with a
    # ".", a prefix based on the current class name will be used. Unless the
    # constant ROSETTA_PREFIX is defined, which will then be used instead.
    macro r(key)
      {% if key.is_a?(StringLiteral) %}
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
      {% else %}
        {%
          raise <<-ERROR
          Only a StringLiteral can be used as a locale key.

            Use case to dynamically switch between locale keys. For example:

              case value
              when "one"
                r("key.option.one").t
              when "two"
                r("key.option.two").t
              else
                r("key.option.fallback").t
              end


          ERROR
        %}
      {% end %}
    end
  end
end
