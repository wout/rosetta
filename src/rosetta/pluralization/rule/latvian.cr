module Rosetta
  module Pluralization
    abstract struct Rule
      # Latvian pluralization rule.
      #
      # This rule was extracted from [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n).
      @[CategoryTags(:one, :other)]
      struct Latvian < Rule
        def apply(count : Float | Int) : Symbol
          if count % 10 == 1 && count % 100 != 11
            :one
          else
            :other
          end
        end
      end
    end
  end
end
