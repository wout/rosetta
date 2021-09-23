module Rosetta
  module Pluralization
    abstract class Rule
      # Colognian pluralization rule.
      #
      # This rule was extracted from [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n).
      @[CategoryTags(:zero, :one, :other)]
      class Colognian < Rule
        def apply(count : Float | Int) : Symbol
          if count == 0
            :zero
          elsif count == 1
            :one
          else
            :other
          end
        end
      end
    end
  end
end
