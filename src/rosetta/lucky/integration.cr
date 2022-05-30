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

class Lucky::FlashStore
  {% for shortcut in [:failure, :info, :success] %}
    def {{ shortcut.id }}=(message : Rosetta::Translation)
      set(:{{ shortcut.id }}, message.t)
    end
  {% end %}

  def set(key : Key, value : Rosetta::Translation) : String
    set(key, value.t)
  end
end

module Lucky::SpecialtyTags
  def raw(string : Rosetta::Translation) : Nil
    view << string.t
  end
end

module Lucky::FormHelpers
  def submit(text : Rosetta::Translation, **html_options) : Nil
    submit(text.t, **html_options)
  end
end
