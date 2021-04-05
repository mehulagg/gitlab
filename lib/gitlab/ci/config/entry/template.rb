# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents a template metadata.
        #
        class Template < ::Gitlab::Config::Entry::Node
          include ::Gitlab::Config::Entry::Validatable

          ALLOWED_KEYS = %i[category name description type maintainer].freeze

          validations do
            validates :config, hash: true
            validates :config, allowed_keys: ALLOWED_KEYS

            with_options if: :template? do
              validates :category, type: String, inclusion: { in: GitLab::Ci::Template.all_categories }
              validates :name, type: String, length: { in: 1..50 }
              validates :description, type: String, length: { in: 10..10_000 }
              validates :type, type: String, inclusion: { in: GitLab::Ci::Template.all_types }
              validates :maintainer, type: String, length: { in: 10..10_000 }
            end
          end

          def template?
            # TODO:
          end
        end
      end
    end
  end
end
