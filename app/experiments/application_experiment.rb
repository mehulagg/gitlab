# frozen_string_literal: true

class ApplicationExperiment < Gitlab::Experiment # rubocop:disable Gitlab/NamespacedClass
  SEED = ENV['EXPERIMENT_PSEUDO_ANONYMIZATION_SEED']

  def enabled?
    return false if Feature::Definition.get(feature_flag_name).nil? # there has to be a feature flag yaml file
    return false unless Gitlab.dev_env_or_com? # we have to be in an environment that allows experiments

    # the feature flag has to be rolled out
    Feature.get(feature_flag_name).state != :off # rubocop:disable Gitlab/AvoidFeatureGet
  end

  def publish(_result = nil)
    return unless should_track? # don't track events for excluded contexts

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
    Gitlab::Tracking.event(name, action.to_s, **pseudo_anonymized(event_args).merge(
      context: (event_args[:context] || []) << SnowplowTracker::SelfDescribingJson.new(
        'iglu:com.gitlab/gitlab_experiment/jsonschema/1-0-0', signature
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

  def pseudo_anonymized(in_args)
    in_args.each_with_object({}) do |(k, v), hash|
      if v.respond_to?(:to_global_id)
        hash["anonymized_#{k}".to_sym] = key_for(v, SEED)
      else
        hash[k] = v
      end
    end
  end
end
