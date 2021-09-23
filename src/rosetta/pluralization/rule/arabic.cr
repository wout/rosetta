module Rosetta
  module Pluralization
    abstract class Rule
      # Arabic pluralization rule.
      #
      # This rule was extracted from [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n).
      @[CategoryTags(:zero, :one, :two, :few, :many, :other)]
      class Arabic < Rule
        def apply(count : Float | Int) : Symbol
          mod100 = count % 100

          if count == 0
            :zero
          elsif count == 1
            :one
          elsif count == 2
            :two
          elsif FROM_3_TO_10.includes?(mod100)
            :few
          elsif FROM_11_TO_99.includes?(mod100)
            :many
          else
            :other
          end
        end

        private FROM_3_TO_10  = (3..10).to_a
        private FROM_11_TO_99 = (11..99).to_a
      end
    end
  end
end
