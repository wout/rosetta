module Rosetta
  module Lucky
    # Includes `Rosetta::Translatable` where it may be required.
    macro integrate
      {% targets = {
           "Avram::Model",
           "Avram::Operation",
           "Avram::SaveOperation(T)",
           "Lucky::Action",
           "Lucky::BaseComponent",
         } %}

      {% for target in targets %}
        abstract class ::{{target.id}}
          include Rosetta::Localizable
          include Rosetta::Translatable
        end
      {% end %}
    end
  end
end

module Lucky::HTMLPage
  macro included
    include Rosetta::Localizable
    include Rosetta::Translatable
  end
end
