module Rosetta
  module Pluralization
    abstract struct Rule
      # Macedonian pluralization rule.
      #
      # This rule was extracted from [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n).
      @[CategoryTags(:one, :other)]
      struct Macedonian < Rule
        def apply(count : Rosetta::CountArg) : Symbol
          if count % 10 == 1 && count != 11
            :one
          else
            :other
          end
        end
      end
    end
  end
end
