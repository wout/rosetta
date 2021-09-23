module Rosetta
  class Parser
    class Config
      include YAML::Serializable

      getter path : String
      getter default_locale : String
      getter available_locales : Array(String)
      getter pluralization_rules : Hash(String, String)
      getter pluralization_tags : Hash(String, Array(String))
    end
  end
end
