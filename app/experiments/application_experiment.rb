# frozen_string_literal: true

class ApplicationExperiment < Gitlab::Experiment # rubocop:disable Gitlab/NamespacedClass
  def enabled?
    return false if Feature::Definition.get(feature_flag_name).nil? # there has to be a feature flag yaml file
    return false unless Gitlab.dev_env_or_com? # we have to be in an environment that allows experiments

    # the feature flag has to be rolled out
    Feature.get(feature_flag_name).state != :off # rubocop:disable Gitlab/AvoidFeatureGet
  end

  def publish(_result = nil)
    return unless should_track? # don't track events for excluded contexts

    record_experiment if @record # record the subject in the database if the context contains a namespace, group, project, actor or user

    track(:assignment) # track that we've assigned a variant for this context

    push_to_client
  end

  # push the experiment data to the client
  def push_to_client
    Gon.push({ experiment: { name => signature } }, true)
  rescue NoMethodError
    # means we're not in the request cycle, and can't add to Gon. Log a warning maybe?
  end

  def track(action, **event_args)
    return unless should_track? # don't track events for excluded contexts

    # track the event, and mix in the experiment signature data
    Gitlab::Tracking.event(name, action.to_s, **event_args.merge(
      context: (event_args[:context] || []) << SnowplowTracker::SelfDescribingJson.new(
        'iglu:com.gitlab/gitlab_experiment/jsonschema/1-0-0', signature
      )
    ))
  end

  def record!
    @record = true
  end

  def exclude!
    @excluded = true
  end

  def control_behavior
    # define a default nil control behavior so we can omit it when not needed
  end

  private

  def feature_flag_name
    name.tr('/', '_')
  end

  def experiment_group?
    Feature.enabled?(feature_flag_name, self, type: :experiment, default_enabled: :yaml)
  end

  def record_experiment
    subject = context.value[:namespace] || context.value[:group] || context.value[:project] || context.value[:user] || context.value[:actor]
    return unless ExperimentSubject.valid_subject?(subject)

    variant = :experimental if @variant_name != :control

    Experiment.add_subject(name, variant: variant || :control, subject: subject)
  end
end
