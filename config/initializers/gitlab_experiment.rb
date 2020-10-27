# frozen_string_literal: true

# Make Gitlab::Experiment::Context respond to flipper_id so we can pass it to
# flipper nicely while we build out the flipper resolver strategy that has
# context migration built in.
class Gitlab::Experiment::Context
  def flipper_id
    "Experiment;#{@experiment.name};#{signature[:key]}"
  end
end

Gitlab::Experiment.configure do |config|
  # Prefix all experiment names with a given value. Use `nil` for none.
  config.name_prefix = 'gitlab_experiment'

  # Logic this project uses to resolve a variant for a given experiment.
  #
  # This can return an instance of any object that responds to `name`, or can
  # return a variant name as a string, in which case the built in variant
  # class will be used.
  #
  # This block will be executed within the scope of the experiment instance,
  # so can easily access experiment methods, like getting the name or context.
  config.variant_resolver = lambda do |requested_variant|
    # Return the variant if one was requested in code:
    break requested_variant if requested_variant.present?

    # Use Flipper to determine variant by passing the experiment, which
    # responds to `flipper_id`:
    Feature.enabled?(name, context, type: :experiment) ? variant_names.first || 'control' : 'control'
  end

  # Tracking behavior can be implemented to link an event to an experiment.
  #
  # Similar to the variant_resolver, this is called within the scope of the
  # experiment instance and so can access any methods on the experiment,
  # such as name and signature.
  config.tracking_behavior = lambda do |event, args|
    Gitlab::Tracking.event(name, event, **args.merge(
      context: (args[:context] || []) << SnowplowTracker::SelfDescribingJson.new(
        'iglu:com.gitlab/gitlab_experiment/jsonschema/0-3-0', signature
      )
    ))
  end

  # Called at the end of every experiment run, with the result.
  #
  # You may want to track that you've assigned a variant to a given context,
  # or push the experiment into the client or publish results elsewhere, like
  # into redis or postgres. Also called within the scope of the experiment
  # instance.
  config.publishing_behavior = lambda do |result|
    # Track the event using our own configured tracking logic.
    track(:assignment)

    # Push the experiment knowledge into the front end. The signature contains
    # the context key, and the variant that has been determined.
    Gon.push({ experiment: { name => signature } }, true)
    # Log using our logging system, so the result (which can be large) can be
    # reviewed later if we want to.
    #
    # Lograge::Event.log(experiment: name, result: result, signature: signature)
  end
end
