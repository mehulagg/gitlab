# frozen_string_literal: true

require 'spec_helper'

# As each associated, backwards-compatible experiment gets cleaned up and removed from the EXPERIMENTS list, its key will also get removed from this list. Once the list here is empty, we can remove the backwards compatibility code altogether.
# Originally created as part of https://gitlab.com/gitlab-org/gitlab/-/merge_requests/45733 for https://gitlab.com/gitlab-org/gitlab/-/issues/270858.
RSpec.describe Gitlab::Experimentation::EXPERIMENTS do
  it 'temporarily ensures we know what experiments exist for backwards compatibility' do
    expected_experiment_keys = [
      :onboarding_issues,
      :ci_notification_dot,
      :upgrade_link_in_user_menu_a,
      :invite_members_version_a,
      :invite_members_version_b,
      :invite_members_empty_group_version_a,
      :new_create_project_ui,
      :contact_sales_btn_in_app,
      :customize_homepage,
      :invite_email,
      :invitation_reminders,
      :group_only_trials,
      :default_to_issues_board
    ]

    backwards_compatible_experiment_keys = described_class.filter { |_, v| v[:use_backwards_compatible_subject_index] }.keys

    expect(backwards_compatible_experiment_keys).not_to be_empty, "Oh, hey! Let's clean up that :use_backwards_compatible_subject_index stuff now :D"
    expect(backwards_compatible_experiment_keys).to match(expected_experiment_keys)
  end
end

RSpec.describe Gitlab::Experimentation do
  before do
    stub_const('Gitlab::Experimentation::EXPERIMENTS', {
      backwards_compatible_test_experiment: {
        tracking_category: 'Team',
        use_backwards_compatible_subject_index: true
      },
      test_experiment: {
        tracking_category: 'Team'
      }
    })

    Feature.enable_percentage_of_time(:backwards_compatible_test_experiment_experiment_percentage, enabled_percentage)
    Feature.enable_percentage_of_time(:test_experiment_experiment_percentage, enabled_percentage)
    allow(Gitlab).to receive(:com?).and_return(true)
  end

  let(:enabled_percentage) { 10 }

  describe '.active?' do
    subject { described_class.active?(:test_experiment) }

    context 'feature toggle is enabled and we are selected' do
      it { is_expected.to be_truthy }
    end

    describe 'experiment is not defined' do
      it 'returns false' do
        expect(described_class.active?(:missing_experiment)).to be_falsey
      end
    end

    describe 'experiment is disabled' do
      let(:enabled_percentage) { 0 }

      it { is_expected.to be_falsey }
    end
  end

  describe '.enabled?' do
    context 'with new index calculation' do
      let(:experiment_subject) { 'z' }
      let(:enabled_percentage) { 50 }

      subject { described_class.enabled?(:test_experiment, subject: experiment_subject) }

      context 'when experiment is active' do
        before do
          allow(described_class).to receive(:active?).and_return(true)
        end

        context 'when subject is part of the experiment' do
          let(:experiment_subject) { 'z' } # Zlib.crc32('test_experimentz') % 100 = 33

          it { is_expected.to be_truthy }
        end

        context 'when subject is not part of the experiment' do
          let(:experiment_subject) { 'a' } # Zlib.crc32('test_experimenta') % 100 = 61

          it { is_expected.to be_falsey }
        end

        context 'when subject is nil' do
          let(:experiment_subject) { nil }

          it { is_expected.to be_falsey }
        end

        context 'when subject is an empty string' do
          let(:experiment_subject) { '' }

          it { is_expected.to be_falsey }
        end

        context 'when subject has a global_id' do
          let(:experiment_subject) { double(:subject, to_global_id: 'z') }

          it { is_expected.to be_truthy }
        end
      end

      context 'when experiment is not active' do
        before do
          allow(described_class).to receive(:active?).and_return(false)
        end

        it { is_expected.to be_falsey }
      end
    end

    context 'with backwards compatible index calculation' do
      let(:experiment_subject) { 'abc' }
      subject { described_class.enabled?(:backwards_compatible_test_experiment, subject: experiment_subject) }

      context 'when experiment is active' do
        before do
          allow(described_class).to receive(:active?).and_return(true)
        end

        context 'when subject is part of the experiment' do
          let(:experiment_subject) { 'abcd' } # Digest::SHA1.hexdigest('abcd').hex % 100 = 7

          it { is_expected.to be_truthy }
        end

        context 'when subject is not part of the experiment' do
          let(:experiment_subject) { 'abc' } # Digest::SHA1.hexdigest('abc').hex % 100 = 17

          it { is_expected.to be_falsey }
        end

        context 'when subject is nil' do
          let(:experiment_subject) { nil }

          it { is_expected.to be_falsey }
        end

        context 'when subject is an empty string' do
          let(:experiment_subject) { '' }

          it { is_expected.to be_falsey }
        end
      end

      context 'when experiment is not active' do
        before do
          allow(described_class).to receive(:active?).and_return(false)
        end

        it { is_expected.to be_falsey }
      end
    end
  end
end
