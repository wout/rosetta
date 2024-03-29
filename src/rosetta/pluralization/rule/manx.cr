module Rosetta
  module Pluralization
    abstract struct Rule
      # Manx pluralization rule.
      #
      # This rule was extracted from [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n).
      @[CategoryTags(:one, :other)]
      struct Manx < Rule
        def apply(count : Rosetta::CountArg) : Symbol
          if [1, 2].includes?(count % 10) || count % 20 == 0
            :one
          else
            :other
          end
        end
      end
    end
  end
end
