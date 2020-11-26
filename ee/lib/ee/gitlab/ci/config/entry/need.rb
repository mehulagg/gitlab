# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Config
        module Entry
          module Need
            extend ActiveSupport::Concern

            prepended do
              # When defining a bridge that subscribes to an upstream pipeline:
              # needs:pipeline: other/project
              strategy :BridgeHash,
                class: EE::Gitlab::Ci::Config::Entry::Need::BridgeHash,
                if: -> (config) { config.is_a?(Hash) && bridge_to_upstream_pipeline?(config) }

              # When defining DAG dependency across project/ref
              strategy :CrossProjectDependency,
                class: EE::Gitlab::Ci::Config::Entry::Need::CrossProjectDependency,
                if: -> (config) { config.is_a?(Hash) && cross_project_need?(config) }
            end

            class_methods do
              def bridge_to_upstream_pipeline?(config)
                !config.key?(:job) && !config.key?(:project)
              end

              def cross_project_need?(config)
                config.key?(:project) || config.key?(:ref)
              end
            end

            class BridgeHash < ::Gitlab::Config::Entry::Node
              include ::Gitlab::Config::Entry::Validatable
              include ::Gitlab::Config::Entry::Attributable

              ALLOWED_KEYS = %i[pipeline].freeze
              attributes :pipeline

              validations do
                validates :config, presence: true
                validates :config, allowed_keys: ALLOWED_KEYS
                validates :pipeline, type: String, presence: true
              end

              def type
                :bridge
              end
            end

            class CrossProjectDependency < ::Gitlab::Config::Entry::Node
              include ::Gitlab::Config::Entry::Validatable
              include ::Gitlab::Config::Entry::Attributable

              ALLOWED_KEYS = %i[project ref job artifacts].freeze
              attributes :project, :ref, :job, :artifacts

              validations do
                validates :config, presence: true
                validates :config, allowed_keys: ALLOWED_KEYS
                validates :project,  type: String, presence: true
                validates :ref,      type: String, presence: true
                validates :job,      type: String, presence: true
                validates :artifacts, boolean: true, allow_nil: true
              end

              def type
                :cross_dependency
              end

              def value
                super.merge(artifacts: artifacts || artifacts.nil?)
              end
            end
          end
        end
      end
    end
  end
end
