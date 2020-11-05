# frozen_string_literal: true

require 'yaml'

# == Experimentation
#
# Utility module for A/B testing experimental features. Define your experiments in the `lib/gitlab/experimentation/registry.yml` file.
# Experiment options:
# - environment (optional, defaults to enabled for development and GitLab.com)
# - tracking_category (optional, used to set the category when tracking an experiment event)
# - use_backwards_compatible_subject_index (optional, set this to true if you need backwards compatibility)
#
# The experiment is controlled by a Feature Flag (https://docs.gitlab.com/ee/development/feature_flags/controls.html),
# which is named "#{experiment_key}_experiment_percentage" and *must* be set with a percentage and not be used for other purposes.
#
# To enable the experiment for 10% of the users:
#
# chatops: `/chatops run feature set experiment_key_experiment_percentage 10`
# console: `Feature.enable_percentage_of_time(:experiment_key_experiment_percentage, 10)`
#
# To disable the experiment:
#
# chatops: `/chatops run feature delete experiment_key_experiment_percentage`
# console: `Feature.remove(:experiment_key_experiment_percentage)`
#
# To check the current rollout percentage:
#
# chatops: `/chatops run feature get experiment_key_experiment_percentage`
# console: `Feature.get(:experiment_key_experiment_percentage).percentage_of_time_value`
#

# TODO: see https://gitlab.com/gitlab-org/gitlab/-/issues/217490
module Gitlab
  module Experimentation
    class << self
      REGISTRY_FILE_PATH = Rails.root.join('lib', 'gitlab', 'experimentation', 'registry.yml')

      def registry
        @registry ||= YAML.load_file(REGISTRY_FILE_PATH).deep_symbolize_keys
      end

      def experiment(key)
        ::Gitlab::Experimentation::Experiment.new(key, **registry[key])
      end

      def enabled?(experiment_key)
        return false unless registry.key?(experiment_key)

        experiment = experiment(experiment_key)
        experiment.enabled_for_environment? && experiment.enabled?
      end

      def enabled_for_attribute?(experiment_key, attribute)
        index = Digest::SHA1.hexdigest(attribute).hex % 100
        enabled_for_value?(experiment_key, index)
      end

      def enabled_for_value?(experiment_key, value)
        enabled?(experiment_key) && experiment(experiment_key).enabled_for_index?(value)
      end
    end
  end
end
