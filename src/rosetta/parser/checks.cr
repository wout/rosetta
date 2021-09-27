module Rosetta
  class Parser
    module Checks
      # Checks if available locales are present.
      private def check_available_locales_present? : Bool
        return true if (diff = available_locales - translations.keys).empty?

        @error = <<-ERROR
        Expected to find translations for:
        #{pretty_list_for_error(available_locales)}

        But missing all translations for:

        #{pretty_list_for_error(diff)}

        ERROR

        false
      end

      # Checks if all key sets have the same keys as the main locale.
      private def check_key_set_complete? : Bool
        alternative_locales.each do |locale|
          diff = ruling_key_set - translations[locale].keys

          unless diff.empty?
            @error = <<-ERROR
            Missing keys for locale "#{locale}":
            #{pretty_list_for_error(diff)}

            ERROR

            return false
          end
        end

        true
      end

      # Checks if other keys sets don't have more keys than the main locale.
      private def check_key_set_overflowing? : Bool
        alternative_locales.each do |locale|
          diff = translations[locale].keys - ruling_key_set

          unless diff.empty?
            @error = <<-ERROR
            The "#{locale}" locale has unused keys:
            #{pretty_list_for_error(diff)}

            ERROR

            return false
          end
        end

        true
      end

      # Checks if interpolation keys are maching in all available locales.
      private def check_interpolation_keys_matching? : Bool
        errors = ruling_key_set.each_with_object([] of String) do |k, e|
          ruling_translation = processed_translations[k][default_locale]
          i12n_keys = ruling_translation.to_s.scan(/%\{[^\}]+\}/).map { |m| m[0] }

          next if i12n_keys.empty?

          alternative_locales.each do |l|
            i12n_keys.each do |key|
              next if processed_translations[k][l].to_s.match(%r{#{key}})

              e << %(#{l}: "#{k}" should contain "#{key}")
            end
          end
        end

        unless errors.empty?
          @error = <<-ERROR
          Some translations have mismatching interpolation keys:
          #{pretty_list_for_error(errors)}

          ERROR

          return false
        end

        true
      end

      # Check if every locale has the required category tags for every
      # pluralizable translation.
      private def check_pluralization_tags_complete? : Bool
        errors = processed_translations.each_with_object([] of String) do |(k, h), e|
          h.each do |l, t|
            next unless pluralizable_hash?(t)

            diff = pluralization_tags[l] - t.as(Hash).keys

            e << %(#{l}: "#{k}" is missing "#{diff.join(", ")}") unless diff.empty?
          end
        end

        unless errors.empty?
          @error = <<-ERROR
          Some pluralizable translations are missing category tags:
          #{pretty_list_for_error(errors)}

          ERROR

          return false
        end

        true
      end
    end
  end
end
