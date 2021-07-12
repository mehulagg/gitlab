# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents a CI/CD template metadata.
        #
        class TemplateMetadata < ::Gitlab::Config::Entry::Node
          include ::Gitlab::Config::Entry::Validatable
          include ::Gitlab::Config::Entry::Configurable
          include ::Gitlab::Config::Entry::Attributable

          ALLOWED_KEYS = %i[name desc stages categories maintainers usage inclusion_type].freeze
          AVAILABLE_USAGES = %w[copy-paste inclusion].freeze
          AVAILABLE_INCLUSION_TYPES = %w[shared-workflow workflow-extension composable-job other].freeze

          attributes ALLOWED_KEYS

          validations do
            validates :config, type: Hash
            validates :config, allowed_keys: ALLOWED_KEYS
            validates :name, presence: true, type: String, length: { maximum: 80 }

            validates :usage, presence: true, type: String,
                      inclusion: {
                        in: AVAILABLE_USAGES,
                        message: "must be one of #{AVAILABLE_USAGES.join(', ')}"
                      }

            validates :inclusion_type, presence: true, type: String,
                      inclusion: {
                        in: AVAILABLE_INCLUSION_TYPES,
                        message: "must be one of #{AVAILABLE_INCLUSION_TYPES.join(', ')}"
                      },
                      if: :inclusion_usage?

            validates :inclusion_type, absence: true,
                      unless: :inclusion_usage?

            with_options allow_nil: true do
              validates :desc, presence: true, type: String, length: { maximum: 5000 }
              validates :stages, array_of_strings: true
              validates :categories, array_of_strings: true
              validates :maintainers, array_of_strings: true
            end

            def inclusion_usage?
              self.usage == 'inclusion'
            end
          end
        end
      end
    end
  end
end
