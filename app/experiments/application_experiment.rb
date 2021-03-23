# frozen_string_literal: true

class ApplicationExperiment < Gitlab::Experiment # rubocop:disable Gitlab/NamespacedClass
  def enabled?
    return false if Feature::Definition.get(feature_flag_name).nil? # there has to be a feature flag yaml file
    return false unless Gitlab.dev_env_or_com? # we have to be in an environment that allows experiments

    # the feature flag has to be rolled out
    Feature.get(feature_flag_name).state != :off # rubocop:disable Gitlab/AvoidFeatureGet
  end

  def publish(result = nil)
    return unless should_track? # don't track events for excluded contexts

    log_performance(result) if result.present? # log performance details
    track(:assignment) # track that we've assigned a variant for this context

    begin
      Gon.push({ experiment: { name => signature } }, true) # push the experiment data to the client
    rescue NoMethodError
      # means we're not in the request cycle, and can't add to Gon. Log a warning maybe?
    end
  end

  def track(action, **event_args)
    return unless should_track? # don't track events for excluded contexts

    # track the event, and mix in the experiment signature data
    Gitlab::Tracking.event(name, action.to_s, **event_args.merge(
      context: (event_args[:context] || []) << SnowplowTracker::SelfDescribingJson.new(
        'iglu:com.gitlab/gitlab_experiment/jsonschema/0-3-0', signature
      )
    ))
  end

  def exclude!
    @excluded = true
  end

  private

  def feature_flag_name
    name.tr('/', '_')
  end

  def experiment_group?
    Feature.enabled?(feature_flag_name, self, type: :experiment, default_enabled: :yaml)
  end

  def log_performance(result)
    Gitlab::Metrics.add_event("gitlab_#{feature_flag_name}_experiment_run".to_sym, {
      duration: result.observations.first.duration,
      variant: variant.name
    })
  end
end
