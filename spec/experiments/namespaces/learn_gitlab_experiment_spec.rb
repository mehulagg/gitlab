# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Namespaces::LearnGitlabExperiment do
  include AfterNextHelpers

  describe '#enabled?' do
    using RSpec::Parameterized::TableSyntax

    let_it_be(:user) { build(:user) }
    let_it_be(:namespace) { build(:group, owner: user) }

    subject(:enabled?) { described_class.new(user, namespace).enabled? }

    where(:experiment_a, :experiment_b, :onboarding, :learn_gitlab_available, :result) do
      true        | false         | true        | true                  | true
      false       | true          | true        | true                  | true
      false       | false         | true        | true                  | false
      true        | true          | true        | false                 | false
      true        | true          | false       | true                  | false
    end

    with_them do
      before do
        stub_experiment_for_subject(learn_gitlab_a: experiment_a, learn_gitlab_b: experiment_b)
        allow(OnboardingProgress).to receive(:onboarding?).with(namespace).and_return(onboarding)
        allow_next(LearnGitlab, user).to receive(:available?).and_return(learn_gitlab_available)
      end

      it { is_expected.to eq(result) }

      context 'when user is nil' do
        let(:user) { nil }

        it { is_expected.to eq(false) }
      end
    end
  end
end
