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
        errors = ruling_key_set.each_with_object([] of String) do |key, err|
          ruling_translation = processed_translations[key][default_locale]
          i12n_keys = ruling_translation.to_s.scan(/%\{[^\}]+\}/)
            .map { |match| match[0] }

          next if i12n_keys.empty?

          alternative_locales.each do |locale|
            i12n_keys.each do |i12n_key|
              next if processed_translations[key][locale].to_s.match(%r{#{i12n_key}})

              err << %(#{locale}: "#{key}" should contain "#{i12n_key}")
            end
          end
        end

        return true if errors.empty?

        @error = <<-ERROR
        Some translations have mismatching interpolation keys:
        #{pretty_list_for_error(errors)}

        ERROR

        false
      end

      # Check if every locale has the required category tags for every
      # pluralizable translation.
      private def check_pluralization_tags_complete? : Bool
        errors = processed_translations
          .each_with_object([] of String) do |(key, hash), err|
            hash.each do |locale, trans|
              next unless pluralizable_hash?(trans)

              locale = pluralization_tags[locale]? ? locale : locale[0, 2]
              diff = pluralization_tags[locale] - trans.as(Hash).keys

              unless diff.empty?
                err << %(#{locale}: "#{key}" is missing "#{diff.join(", ")}")
              end
            end
          end

        return true if errors.empty?

        @error = <<-ERROR
        Some pluralizable translations are missing category tags:
        #{pretty_list_for_error(errors)}

        ERROR

        false
      end

      private def check_variant_keys_matching? : Bool
        errors = processed_translations
          .each_with_object([] of String) do |(key, _), err|
            next unless variants_key?(key.to_s)

            ruling_variants = processed_translations[key][default_locale].as(Hash).keys

            alternative_locales.each do |locale|
              diff = ruling_variants - processed_translations[key][locale].as(Hash).keys

              unless diff.empty?
                err << %(#{locale}: "#{key}" is missing "#{diff.join(", ")}")
              end
            end
          end

        return true if errors.empty?

        @error = <<-ERROR
        Some translations with variants have mismatching keys:
        #{pretty_list_for_error(errors)}

        ERROR

        false
      end

      # private def check_nested_keys_present?
      #   errors = translations
      #     .each_with_object([] of String) do |(locale, t10s), err|
      #       t10s.each do |key, value|
      #         next unless value.is_a?(String)
      #         next unless value.includes?("%r{")
      #         next unless m = value.match(NESTED_KEY_REGEX)
      #         next if t10s[m[1]]?
      #
      #         err << %(#{locale}: "#{key}" references missing key "#{m[1]}")
      #       end
      #     end
      #
      #   return true if errors.empty?
      #
      #   @error = <<-ERROR
      #   Some nested keys could not be resolved:
      #   #{pretty_list_for_error(errors)}
      #
      #   ERROR
      #
      #   false
      # end
    end
  end
end
