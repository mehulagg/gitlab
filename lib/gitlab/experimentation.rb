# frozen_string_literal: true

# == Experimentation
#
# Utility module for A/B testing experimental features. Define your experiments in the `EXPERIMENTS` constant.
# Experiment options:
# - tracking_category (optional, used to set the category when tracking an experiment event)
# - use_backwards_compatible_subject_index (optional, set this to true if you need backwards compatibility -- you likely do not need this, see note in the next paragraph.)
#
# Using the backwards-compatible subject index (use_backwards_compatible_subject_index option):
# This option was added when [the calculation of experimentation_subject_index was changed](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/45733/diffs#41af4a6fa5a10c7068559ce21c5188483751d934_157_173). It is not intended to be used by new experiments, it exists merely for the segmentation integrity of in-flight experiments at the time the change was deployed. That is, we want users who were assigned to the "experimental" group or the "control" group before the change to still be in those same groups after the change. See [the original issue](https://gitlab.com/gitlab-org/gitlab/-/issues/270858) and [this related comment](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/48110#note_458223745) for more information.
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
      def get_experiment(experiment_key)
        klass = "#{experiment_key}_experiment".safe_constantize

        return unless klass

        klass.new
      end

      def active?(experiment_key)
        experiment = get_experiment(experiment_key)
        return false unless experiment

        experiment.active?
      end

      def in_experiment_group?(experiment_key, subject:)
        return false if subject.blank?
        return false unless active?(experiment_key)

        experiment = get_experiment(experiment_key)
        return false unless experiment

        experiment.enabled_for_index?(index_for_subject(experiment, subject))
      end

      private

      def index_for_subject(experiment, subject)
        index = if experiment.use_backwards_compatible_subject_index
                  Digest::SHA1.hexdigest(subject_id(subject)).hex
                else
                  Zlib.crc32("#{experiment.key}#{subject_id(subject)}")
                end

        index % 100
      end

      def subject_id(subject)
        if subject.respond_to?(:to_global_id)
          subject.to_global_id.to_s
        elsif subject.respond_to?(:to_s)
          subject.to_s
        else
          raise ArgumentError.new('Subject must respond to `to_global_id` or `to_s`')
        end
      end
    end
  end
end
