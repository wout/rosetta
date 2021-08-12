module Rosetta
  module Backend
    macro load(path)
      TRANSLATIONS = {{ run("./parser", path) }}
    end

    macro look_up(key)
      {%
        translation = TRANSLATIONS[key]

        if translation.is_a?(NilLiteral)
          raise <<-ERROR
          Missing translation for #{key}.
          ERROR
        end
      %}

      {{ translation }}
    end
  end
end
