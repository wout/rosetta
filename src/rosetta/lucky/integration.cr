module Rosetta
  module Lucky
    macro integrate
      {% targets = {
           "Avram::Model",
           "Avram::Operation",
           "Avram::DeleteOperation(T)",
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

      module ::Lucky::HTMLPage
        macro included
          include Rosetta::Localizable
          include Rosetta::Translatable
        end
      end

      module ::Lucky::AllowedInTags
      end

      module Rosetta::SimpleTranslation
        macro included
          include ::Lucky::AllowedInTags
        end
      end

      abstract struct ::Avram::I18nBackend; end

      struct Rosetta::AvramBackend < ::Avram::I18nBackend
        def get(key : String | Symbol) : String
          {% begin %}
            case key
            {% for val in %w[
                            exact_size_of
                            max_size_of
                            min_size_of
                            numeric_max
                            numeric_min
                          ] %}
            when :validate_{{val.id}}
              Rosetta.find("avram.validate_{{val.id}}").t(size: "%d")
            {% end %}
            {% for val in %w[
                            acceptance_of
                            at_most_one_filled
                            confirmation_of
                            exactly_one_filled
                            format_of
                            inclusion_of
                            numeric_nil
                            required
                            uniqueness_of
                          ] %}
            when :validate_{{val.id}}
              Rosetta.find("avram.validate_{{val.id}}").t
            {% end %}
            else
              raise "Avram translation missing for '#{key}'"
            end
          {% end %}
        end
      end
    end
  end
end
