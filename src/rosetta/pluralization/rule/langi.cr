module Rosetta
  module Pluralization
    abstract struct Rule
      # Langi pluralization rule.
      #
      # This rule was extracted from [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n).
      @[CategoryTags(:zero, :one, :other)]
      struct Langi < Rule
        def apply(count : Rosetta::CountArg) : Symbol
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
