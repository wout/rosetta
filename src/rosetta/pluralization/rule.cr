module Rosetta
  module Pluralization
    # Abstract pluralization rule.
    #
    # A pluralization rule struct provides a main `#rule` method that, given a
    # `count` number, returns the corresponding plural category tag, which
    # should be part of the common plural category tags defined
    # [by the CLDR](http://cldr.unicode.org/index/cldr-spec/plural-rules):
    #
    # `:zero`, `:one`, `:two`, `:few`, `:many` and `:other`.
    abstract struct Rule
      abstract def apply(count : Float | Int) : Symbol
    end

    annotation CategoryTags
    end
  end
end
