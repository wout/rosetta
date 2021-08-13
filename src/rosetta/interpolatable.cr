module Rosetta
  class Interpolatable
    def initialize(@string : String)
    end

    def interpolate(values : NamedTuple)
      @string
    end
  end
end
