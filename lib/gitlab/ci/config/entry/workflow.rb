# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        class Workflow < ::Gitlab::Config::Entry::Node
          include ::Gitlab::Config::Entry::Configurable

          ALLOWED_KEYS = %i[rules].freeze

          DEFAULT_RULES = [
            { if: "$CI_COMMIT_BRANCH" },
            { if: "$CI_COMMIT_TAG" }
          ].freeze

          validations do
            validates :config, type: Hash
            validates :config, allowed_keys: ALLOWED_KEYS
            validates :config, presence: true
          end

          entry :rules, Entry::Rules,
            description: 'List of evaluable Rules to determine Pipeline status.',
            metadata: { allowed_when: %w[always never] },
            default: DEFAULT_RULES,
        end
      end
    end
  end
end
