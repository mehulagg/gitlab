# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Matching::RunnerMatcher do
  let(:dummy_attributes) do
    {
      runner_type: 'instance_type',
      public_projects_minutes_cost_factor: 0,
      private_projects_minutes_cost_factor: 1,
      run_untagged: false,
      access_level: 'ref_protected',
      tag_list: %w[tag1 tag2]
    }
  end

  subject(:matcher) { described_class.new(attributes) }

  describe '.new' do
    context 'when attributes are missing' do
      let(:attributes) { {} }

      it { expect { matcher }.to raise_error(KeyError) }
    end

    context 'with attributes' do
      let(:attributes) { dummy_attributes }

      it { expect(matcher.runner_type).to eq('instance_type') }

      it { expect(matcher.public_projects_minutes_cost_factor).to eq(0) }

      it { expect(matcher.private_projects_minutes_cost_factor).to eq(1) }

      it { expect(matcher.run_untagged).to eq(false) }

      it { expect(matcher.access_level).to eq('ref_protected') }

      it { expect(matcher.tag_list).to eq(%w[tag1 tag2]) }
    end
  end

  describe '.for' do
    it 'delegates to factory' do
      expect(described_class::Factory)
        .to receive(:new)
        .with(:my_record)
        .and_return(double(create: []))

      described_class.for(:my_record)
    end
  end

  describe '#instance_type?' do
    let(:attributes) { dummy_attributes }

    it { expect(matcher.instance_type?).to be_truthy }

    context 'context with private runners' do
      let(:attributes) { dummy_attributes.merge(runner_type: 'project_type') }

      it { expect(matcher.instance_type?).to be_falsey }
    end
  end

  describe '#matches?' do
    let(:build) { build_stubbed(:ci_build, build_attributes) }
    let(:runner_matcher) { described_class.new(dummy_attributes.merge(runner_attributes)) }

    subject { runner_matcher.matches?(record) }

    shared_examples 'matches builds to runners' do
      using RSpec::Parameterized::TableSyntax

      where(:ref_protected, :build_protected, :run_untagged, :runner_tags, :build_tags, :result) do
        # the `ref_protected? && !build.protected?` part:
        true              | true            | true         | []          | []         | true
        true              | false           | true         | []          | []         | false
        false             | true            | true         | []          | []         | true
        false             | false           | true         | []          | []         | true
        # `accepting_tags?(build)` bit:
        true              | true            | true         | []          | []         | true
        true              | true            | true         | []          | ['a']      | false
        true              | true            | true         | %w[a b]     | ['a']      | true
        true              | true            | true         | ['a']       | %w[a b]    | false
        true              | true            | true         | ['a']       | ['a']      | true
        true              | true            | false        | ['a']       | ['a']      | true
        true              | true            | false        | ['b']       | ['a']      | false
        true              | true            | false        | %w[a b]     | ['a']      | true
      end

      with_them do
        let(:build_attributes) do
          {
            tag_list: build_tags,
            protected: build_protected
          }
        end

        let(:runner_attributes) do
          {
            access_level: ref_protected ? 'ref_protected' : 'not_protected',
            run_untagged: run_untagged,
            tag_list: runner_tags
          }
        end

        it { is_expected.to eq(result) }
      end
    end

    context 'with an instance of BuildMatcher' do
      it_behaves_like 'matches builds to runners' do
        let(:record) { Gitlab::Ci::Matching::BuildMatcher.for(build).first }
      end
    end

    context 'with an instance of Ci::Build' do
      it_behaves_like 'matches builds to runners' do
        let(:record) { build }
      end
    end
  end
end
