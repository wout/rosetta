module Rosetta
  class Translator
    property backends : Array(Backend::Base)

    def initialize(@backends : Array(Backend::Base) = Array(Backend::Base).new)
    end

    def translate
    end

    def t
    end
  end
end
