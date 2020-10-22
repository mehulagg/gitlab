# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents a release configuration.
        #
        class Release < ::Gitlab::Config::Entry::Node
          include ::Gitlab::Config::Entry::Configurable
          include ::Gitlab::Config::Entry::Validatable
          include ::Gitlab::Config::Entry::Attributable

          ALLOWED_KEYS = %i[tag_name name description ref package_name upload_dir released_at milestones assets].freeze
          PACKAGE_NAME_ERROR_MESSAGE = "can contain only lowercase letters (a-z), uppercase letter (A-Z), numbers (0-9), dots (.), hyphens (-), or underscores (_)"
          attributes %i[tag_name name ref package_name milestones assets].freeze
          attr_reader :released_at

          # Attributable description conflicts with
          # ::Gitlab::Config::Entry::Node.description
          def has_description?
            true
          end

          def description
            config[:description]
          end

          entry :assets, Entry::Release::Assets, description: 'Release assets.'

          validations do
            validates :config, allowed_keys: ALLOWED_KEYS
            validates :tag_name, type: String, presence: true
            validates :description, type: String, presence: true
            validates :package_name, format: { with: API::API::NO_SLASH_URL_PART_REGEX, message: PACKAGE_NAME_ERROR_MESSAGE }, allow_blank: true
            validates :milestones, array_of_strings_or_string: true, allow_blank: true
            validate do
              next unless config[:released_at]

              begin
                @released_at = DateTime.iso8601(config[:released_at])
              rescue ArgumentError
                errors.add(:released_at, "must be a valid datetime")
              end
            end
            validate do
              next unless config[:ref]
              next if Commit.reference_valid?(config[:ref])
              next if Gitlab::GitRefValidator.validate(config[:ref])

              errors.add(:ref, "must be a valid ref")
            end
          end

          def value
            @config[:assets] = assets_value if @config.key?(:assets)
            @config
          end
        end
      end
    end
  end
end
