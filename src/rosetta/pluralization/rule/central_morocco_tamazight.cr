module Rosetta
  module Pluralization
    abstract struct Rule
      # Central Morocco Tamazight pluralization rule.
      #
      # This rule was extracted from [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n).
      @[CategoryTags(:one, :other)]
      struct CentralMoroccoTamazight < Rule
        def apply(count : Rosetta::CountArg) : Symbol
          if ([0, 1] + (11..99).to_a).includes?(count)
            :one
          else
            :other
          end
        end
      end
    end
  end
end
