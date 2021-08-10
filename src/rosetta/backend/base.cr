module Rosetta
  module Backend
    abstract class Base
      macro load(path)
        {% parser_name = @type.name.split("::").last.underscore %}

        {{@type.name}}.new({{ run(["./parser", parser_name].join('/'), path) }})
      end

      def initialize(@translations : Hash(String, Hash(String, String)))
      end

      def look_up(locale : String, key : String) : String?
        @translations.dig?(locale, key)
      end
    end
  end
end
