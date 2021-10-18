module Rosetta
  # Include this module in any class where you need to translate many keys.
  module Translatable
    # Finds the translation for the given key. If the given key starts with a
    # ".", a prefix based on the current class name will be used. Unless a
    # `Rosetta::Translatable::Config` annotation is defined with a value for
    # `prefix`, which will then be used instead.
    #
    # @[Rosetta::Translatable::Config(prefix: "user")]
    # class Person
    #   include Rosetta::Translatable
    #
    #   def greeting
    #     r(".welcome_message").t # => key resolves to "user.welcome_message"
    #   end
    # end
    macro r(key)
      {% if key.is_a?(StringLiteral) %}
        {%
          if key.starts_with?('.')
            config = @type.annotation(Rosetta::Translatable::Config)

            if config && config[:prefix]
              key = "#{config[:prefix].id}#{key.id}"
            else
              inferred_key = @type.id.underscore.gsub(/::|\(/, ".").gsub(/\)/, "")

              key = "#{inferred_key.id}#{key.id}"
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

    annotation Config
    end
  end
end
