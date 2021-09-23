module Rosetta
  module Pluralization
    abstract class Rule
      # Pluralization rule used for: French, Fulah, Kabyle.
      #
      # This rule was extracted from [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n).
      @[CategoryTags(:one, :other)]
      class OneUpToTwoOther < Rule
        def apply(count : Float | Int) : Symbol
          count >= 0 && count < 2 ? :one : :other
        end
      end
    end
  end
end
