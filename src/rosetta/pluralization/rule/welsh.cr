module Rosetta
  module Pluralization
    abstract struct Rule
      # Welsh pluralization rule.
      #
      # This rule was extracted from [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n).
      @[CategoryTags(:zero, :one, :two, :few, :many, :other)]
      struct Welsh < Rule
        def apply(count : Float | Int) : Symbol
          case count
          when 0
            :zero
          when 1
            :one
          when 2
            :two
          when 3
            :few
          when 6
            :many
          else
            :other
          end
        end
      end
    end
  end
end
