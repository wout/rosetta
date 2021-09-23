module Rosetta
  module Pluralization
    abstract class Rule
      # Langi pluralization rule.
      #
      # This rule was extracted from [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n).
      @[CategoryTags(:zero, :one, :other)]
      class Langi < Rule
        def apply(count : Float | Int) : Symbol
          if count == 0
            :zero
          elsif count > 0 && count < 2
            :one
          else
            :other
          end
        end
      end
    end
  end
end
