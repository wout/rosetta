module Rosetta
  module Pluralization
    abstract struct Rule
      # Pluralization rule used for: Cornish, Inari Sami, Inuktitut, Lule Sami, Nama, Northern Sami, Sami Language,
      # Skolt Sami, Southern Sami.
      #
      # This rule was extracted from [crystal-i18n/i18n](https://github.com/crystal-i18n/i18n).
      @[CategoryTags(:one, :two, :other)]
      struct OneTwoOther < Rule
        def apply(count : Float | Int) : Symbol
          if count == 1
            :one
          elsif count == 2
            :two
          else
            :other
          end
        end
      end
    end
  end
end
