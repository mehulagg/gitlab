# frozen_string_literal: true

# Require the provided spec helper and matchers.
require 'gitlab/experiment/rspec'
require_relative 'stub_snowplow'

# This is a temporary fix until we have a larger discussion around the
# challenges raised in https://gitlab.com/gitlab-org/gitlab/-/issues/300104
require Rails.root.join('app', 'experiments', 'application_experiment')
class ApplicationExperiment # rubocop:disable Gitlab/NamespacedClass
  def initialize(...)
    super(...)
    Feature.persist_used!(feature_flag_name)
  end

  def should_track?
    true
  end
end

module Gitlab
  class Experiment
    module RspecHelpers
      def stub_experiments(experiments, times = nil)
        experiments.each { |experiment| stub_experiment_and_tap(experiment, times) }
      end

      def stub_experiment_and_tap(experiment, times = nil, expected = false, &block)
        if experiment.is_a?(Symbol)
          experiment_name, variant_name = experiment, nil
        end

        if experiment.is_a?(Array)
          experiment_name, variant_name = *experiment
        end

        base_klass = Configuration.base_class.constantize
        if experiment.is_a?(base_klass)
          variant_name = experiment.variant.name
        end

        if experiment.class.name.nil? # Anonymous class
          klass = experiment.class
        elsif experiment.instance_of?(Class) # Class level stubbing, eg. "MyExperiment"
          klass = experiment
        else
          experiment_name ||= experiment.instance_variable_get(:@name)
          klass = base_klass.constantize(experiment_name)
        end

        # Set expectations on experiment classes so we can and_wrap_original with more specific args
        experiment_klasses = base_klass.descendants.reject { |k| k == klass }
        experiment_klasses.push(base_klass).each do |k|
          allow(k).to receive(:new).and_call_original
        end

        # Be specific for BaseClass calls
        receiver = receive(:new)

        if experiment_name && klass == base_klass
          experiment_name = experiment_name.to_sym

          # For experiment names like: "group/experiment-name"
          experiment_name = experiment_name.to_s if experiment_name.inspect.include?('"')

          receiver = receiver.with(experiment_name, any_args)
        end

        if times
          receiver.exactly(times).times
        end

        # Set expectations on experiment class of interest
        allow_or_expect_klass = expected ? expect(klass) : allow(klass)

        allow_or_expect_klass.to receiver.and_wrap_original do |method, *original_args, &original_block|
          method.call(*original_args).tap do |e|
            # Stub internal methods before calling the original_block
            allow(e).to receive(:enabled?).and_return(true)

            if variant_name == true # passing true allows the rollout to do its job
              allow(e).to receive(:experiment_group?).and_return(true)
            else
              allow(e).to receive(:resolve_variant_name).and_return(variant_name.to_s)
            end

            # Stub/set expectations before calling the original_block
            yield e if block_given?

            original_block.call(e) if original_block.present?
          end
        end
      end
    end

    module RSpecMatchers
      extend RSpec::Matchers::DSL

      matcher :track do |event, *event_args|
        match do |experiment|
          expect_tracking_on(experiment, false, event, *event_args)
        end

        match_when_negated do |experiment|
          expect_tracking_on(experiment, true, event, *event_args)
        end

        chain :for do |expected_variant|
          raise ArgumentError, 'variant name must be provided' if expected.blank?

          @expected_variant = expected_variant.to_s
        end

        chain(:with_context) { |expected_context| @expected_context = expected_context }

        chain(:on_next_instance) { @on_next_instance = true }

        def expect_tracking_on(experiment, negated, event, *event_args)
          klass = experiment.instance_of?(Class) ? experiment : experiment.class
          unless klass <= Gitlab::Experiment
            raise(
              ArgumentError,
              "track matcher is limited to experiment instances and classes"
            )
          end

          expectations = proc do |e|
            @experiment = e
            allow(e).to receive(:track).and_call_original

            if negated
              expect(e).not_to receive(:track).with(*[event, *event_args])
            else
              if @expected_variant
                expect(@experiment.variant.name).to eq(@expected_variant), failure_message(:variant, event)
              end

              if @expected_context
                expect(@experiment.context.value).to include(@expected_context), failure_message(:context, event)
              end

              expect(e).to receive(:track).with(*[event, *event_args]).and_call_original
            end
          end

          if experiment.instance_of?(Class) || @on_next_instance
            stub_experiment_and_tap(experiment, nil, true) {|e| expectations.call(e) }
          else
            expectations.call(experiment)
          end
        end

        def failure_message(failure_type, event)
          case failure_type
          when :variant
            <<~MESSAGE.strip
              expected #{@experiment.inspect} to have tracked #{event.inspect} for variant
                  expected variant: #{@expected_variant}
                    actual variant: #{@experiment.variant.name}
            MESSAGE
          when :context
            <<~MESSAGE.strip
              expected #{@experiment.inspect} to have tracked #{event.inspect} with context
                  expected context: #{@expected_context}
                    actual context: #{@experiment.context.value}
            MESSAGE
          when :no_new
            %(expected #{@experiment.inspect} to have tracked #{event.inspect}, but no new instances were created)
          end
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include StubSnowplow, :experiment
  config.include Gitlab::Experiment::RspecHelpers
  config.include Gitlab::Experiment::RSpecMatchers, :experiment

  # Disable all caching for experiments in tests.
  config.before do
    allow(Gitlab::Experiment::Configuration).to receive(:cache).and_return(nil)
  end

  config.before(:each, :experiment) do
    stub_snowplow
  end
end
