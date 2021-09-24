module Rosetta
  module Pluralization
    abstract struct Rule
      # Polish pluralization rule.
      #
      # This rule was extracted from [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n).
      @[CategoryTags(:one, :few, :many, :other)]
      struct Polish < Rule
        def apply(count : Float | Int) : Symbol
          mod10 = count % 10
          mod100 = count % 100

          if count == 1
            :one
          elsif [2, 3, 4].includes?(mod10) && ![12, 13, 14].includes?(mod100)
            :few
          elsif ([0, 1] + (5..9).to_a).includes?(mod10) || [12, 13, 14].includes?(mod100)
            :many
          else
            :other
          end
        end
      end
    end
  end
end
