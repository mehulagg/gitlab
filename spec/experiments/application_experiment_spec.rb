# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApplicationExperiment, :experiment do
  subject { described_class.new('namespaced/stub') }

  let(:feature_definition) do
    { name: 'namespaced_stub', type: 'experiment', group: 'group::adoption', default_enabled: false }
  end

  around do |example|
    Feature::Definition.definitions[:namespaced_stub] = Feature::Definition.new('namespaced_stub.yml', feature_definition)
    example.run
    Feature::Definition.definitions.delete(:namespaced_stub)
  end

  before do
    allow(subject).to receive(:enabled?).and_return(true)
  end

  it "naively assumes a 1x1 relationship to feature flags for tests" do
    expect(Feature).to receive(:persist_used!).with('namespaced_stub')

    described_class.new('namespaced/stub')
  end

  describe "enabled" do
    before do
      allow(subject).to receive(:enabled?).and_call_original

      allow(Feature::Definition).to receive(:get).and_return('_instance_')
      allow(Gitlab).to receive(:dev_env_or_com?).and_return(true)
      allow(Feature).to receive(:get).and_return(double(state: :on))
    end

    it "is enabled when all criteria are met" do
      expect(subject).to be_enabled
    end

    it "isn't enabled if the feature definition doesn't exist" do
      expect(Feature::Definition).to receive(:get).with('namespaced_stub').and_return(nil)

      expect(subject).not_to be_enabled
    end

    it "isn't enabled if we're not in dev or dotcom environments" do
      expect(Gitlab).to receive(:dev_env_or_com?).and_return(false)

      expect(subject).not_to be_enabled
    end

    it "isn't enabled if the feature flag state is :off" do
      expect(Feature).to receive(:get).with('namespaced_stub').and_return(double(state: :off))

      expect(subject).not_to be_enabled
    end
  end

  describe "publishing results" do
    it "tracks the assignment" do
      expect(subject).to receive(:track).with(:assignment)

      subject.publish(nil)
    end

    context "when inside a request cycle" do
      before do
        subject.context.instance_variable_set(:@request, double('Request', headers: 'true'))
      end

      it "pushes the experiment knowledge into the client using Gon" do
        expect(Gon).to receive(:push).with(
          {
            experiment: {
              'namespaced/stub' => { # string key because it can be namespaced
                                     experiment: 'namespaced/stub',
                                     key: '86208ac54ca798e11f127e8b23ec396a',
                                     variant: 'control'
              }
            }
          },
          true
        )

        subject.publish(nil)
      end
    end

    context "when outside a request cycle" do
      it "does not push to gon when outside request cycle" do
        expect(Gon).not_to receive(:push)

        subject.publish(nil)
      end
    end
  end

  it "can exclude from within the block" do
    expect(described_class.new('namespaced/stub') { |e| e.exclude! }).to be_excluded
  end

  describe "tracking events", :snowplow do
    it "doesn't track if we shouldn't track" do
      allow(subject).to receive(:should_track?).and_return(false)

      subject.track(:action)

      expect_no_snowplow_event
    end

    it "tracks the event with the expected arguments and merged contexts" do
      subject.track(:action, property: '_property_', context: [
        SnowplowTracker::SelfDescribingJson.new('iglu:com.gitlab/fake/jsonschema/0-0-0', { data: '_data_' })
      ])

      expect_snowplow_event(
        category: 'namespaced/stub',
        action: 'action',
        property: '_property_',
        context: [
          {
            schema: 'iglu:com.gitlab/fake/jsonschema/0-0-0',
            data: { data: '_data_' }
          },
          {
            schema: 'iglu:com.gitlab/gitlab_experiment/jsonschema/0-3-0',
            data: { experiment: 'namespaced/stub', key: '86208ac54ca798e11f127e8b23ec396a', variant: 'control' }
          }
        ]
      )
    end
  end

  describe "variant resolution" do
    context "when using the default feature flag percentage rollout" do
      it "uses the default value as specified in the yaml" do
        expect(Feature).to receive(:enabled?).with('namespaced_stub', subject, type: :experiment, default_enabled: :yaml)

        expect(subject.variant.name).to eq('control')
      end

      it "returns nil when not rolled out" do
        stub_feature_flags(namespaced_stub: false)

        expect(subject.variant.name).to eq('control')
      end

      context "when rolled out to 100%" do
        it "returns the first variant name" do
          subject.try(:variant1) {}
          subject.try(:variant2) {}

          expect(subject.variant.name).to eq('variant1')
        end
      end
    end

    context "when using the round_robin strategy", :clean_gitlab_redis_shared_state do
      context "when variants aren't supplied" do
        subject :inheriting_class do
          Class.new(described_class) do
            def rollout_strategy
              :round_robin
            end
          end.new('namespaced/stub')
        end

        it "raises an error" do
          expect { inheriting_class.variants }.to raise_error(NotImplementedError)
        end
      end

      context "when variants are supplied" do
        let(:inheriting_class) do
          Class.new(described_class) do
            def rollout_strategy
              :round_robin
            end

            def variants
              %i[variant1 variant2 control]
            end
          end
        end

        it "proves out round robin in variant selection", :aggregate_failures do
          instance_1 = inheriting_class.new('namespaced/stub')
          allow(instance_1).to receive(:enabled?).and_return(true)
          instance_2 = inheriting_class.new('namespaced/stub')
          allow(instance_2).to receive(:enabled?).and_return(true)
          instance_3 = inheriting_class.new('namespaced/stub')
          allow(instance_3).to receive(:enabled?).and_return(true)

          instance_1.try {}

          expect(instance_1.variant.name).to eq('variant2')

          instance_2.try {}

          expect(instance_2.variant.name).to eq('control')

          instance_3.try {}

          expect(instance_3.variant.name).to eq('variant1')
        end
      end
    end
  end

  context "when caching" do
    let(:cache) { Gitlab::Experiment::Configuration.cache }

    before do
      allow(Gitlab::Experiment::Configuration).to receive(:cache).and_call_original

      cache.clear(key: subject.name)

      subject.use { } # setup the control
      subject.try { } # setup the candidate
    end

    it "caches the variant determined by the variant resolver" do
      expect(subject.variant.name).to eq('candidate') # we should be in the experiment

      subject.run

      expect(subject.cache.read).to eq('candidate')
    end

    it "doesn't cache a variant if we don't explicitly provide one" do
      # by not caching "empty" variants, we effectively create a mostly
      # optimal combination of caching and rollout flexibility. If we cached
      # every control variant assigned, we'd inflate the cache size and
      # wouldn't be able to roll out to subjects that we'd already assigned to
      # the control.
      stub_feature_flags(namespaced_stub: false) # simulate being not rolled out

      expect(subject.variant.name).to eq('control') # if we ask, it should be control

      subject.run

      expect(subject.cache.read).to be_nil
    end

    it "caches a control variant if we assign it specifically" do
      # by specifically assigning the control variant here, we're guaranteeing
      # that this context will always get the control variant unless we delete
      # the field from the cache (or clear the entire experiment cache) -- or
      # write code that would specify a different variant.
      subject.run(:control)

      expect(subject.cache.read).to eq('control')
    end

    context "arbitrary attributes" do
      before do
        subject.cache.store.clear(key: subject.name + '_attrs')
      end

      it "sets and gets attributes about an experiment" do
        subject.cache.attr_set(:foo, :bar)

        expect(subject.cache.attr_get(:foo)).to eq('bar')
      end

      it "increments a value for an experiment" do
        expect(subject.cache.attr_get(:foo)).to be_nil

        expect(subject.cache.attr_inc(:foo)).to eq(1)
        expect(subject.cache.attr_inc(:foo)).to eq(2)
      end
    end
  end
end
