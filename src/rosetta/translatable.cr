module Rosetta
  # Include this module anywhere translations need to be added
  module Translatable
    def t(key : String)
      I18n.translate(inferred_key_prefix(key))
    end

    def t(key : String, count : Int32)
      I18n.translate(inferred_key_prefix(key), count: count)
    end

    # In places where current_user / user isn't available be sure to override
    # this method with:
    # `quick_def user_lang, I18n.locale`
    def user_lang : String
      current_user.try(&.lang) || I18n.locale
    end

    # In places where a different key prefix is desired define a period-delimited
    # string to be used instead of a prefix based on the current class name.
    def t_prefix : String?
      nil
    end

    # If the given key starts with a ".", generate the prefix based on the
    # current class name
    private def inferred_key_prefix(key : String) : String
      {% begin %}
        return key unless key.char_at(0) == '.'

        t_prefix || "{{@type.id.underscore.gsub(/::/, ".")}}#{key}"
      {% end %}
    end
  end
end
