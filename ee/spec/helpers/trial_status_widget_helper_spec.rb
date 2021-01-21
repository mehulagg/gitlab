# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TrialStatusWidgetHelper do
  let_it_be(:group) { build(:group) }
  let!(:subscription) { build(:gitlab_subscription, :active_trial, namespace: group) }

  describe '#eligible_for_trial_status_widget_experiment?' do
    subject { helper.eligible_for_trial_status_widget_experiment?(group) }

    context 'when group has an active trial' do
      it { is_expected.to be_truthy }
    end

    context 'when group does not have an active trial' do
      before do
        allow(group).to receive(:trial_active?).and_return(false)
      end

      it { is_expected.to be_falsy }
    end
  end

  describe '#show_trial_status_widget?' do
    let(:experiment_enabled) { true }
    let(:eligible_for_experiment) { true }

    before do
      allow(helper).to receive(:experiment_enabled?).with(:show_trial_status_in_sidebar, subject: group).and_return(experiment_enabled)
      allow(helper).to receive(:eligible_for_trial_status_widget_experiment?).and_return(eligible_for_experiment)
    end

    subject { helper.show_trial_status_widget?(group) }

    context 'when the check_namespace_plan application setting is off' do
      it { is_expected.to be_falsy }
    end

    context 'when the check_namespace_plan application setting is on' do
      before do
        stub_application_setting(check_namespace_plan: true)
      end

      context 'and the experiment is enabled and the user is eligible for it' do
        it { is_expected.to be_truthy }
      end

      context 'but the experiment is not enabled' do
        let(:experiment_enabled) { false }

        it { is_expected.to be_falsy }
      end

      context 'but the user is not eligible for the experiment' do
        let(:eligible_for_experiment) { false }

        it { is_expected.to be_falsy }
      end
    end
  end

  describe '#trial_days_remaining_in_words' do
    subject { helper.trial_days_remaining_in_words(group) }

    context 'when there are 0 days remaining' do
      before do
        subscription.trial_ends_on = Date.current
      end

      it { is_expected.to eq('Gold Trial – 0 days left') }
    end

    context 'when there is 1 day remaining' do
      before do
        subscription.trial_ends_on = Date.current.advance(days: 1)
      end

      it { is_expected.to eq('Gold Trial – 1 day left') }
    end

    context 'when there are 2+ days remaining' do
      before do
        subscription.trial_ends_on = Date.current.advance(days: 13)
      end

      it { is_expected.to eq('Gold Trial – 13 days left') }
    end
  end

  describe '#trial_days_remaining' do
    subject { helper.trial_days_remaining(group) }

    context 'at the beginning of a trial' do
      before do
        subscription.trial_starts_on = Date.current
        subscription.trial_ends_on = Date.current.advance(days: 30)
      end

      it { is_expected.to eq(30) }
    end

    context 'in the middle of a trial' do
      it { is_expected.to eq(15) }
    end

    context 'at the end of a trial' do
      before do
        subscription.trial_starts_on = Date.current.advance(days: -30)
        subscription.trial_ends_on = Date.current
      end

      it { is_expected.to eq(0) }
    end
  end

  describe '#total_trial_duration' do
    subject { helper.total_trial_duration(group) }

    context 'for a default trial duration' do
      it { is_expected.to eq(30) }
    end

    context 'for a custom trial duration' do
      before do
        subscription.trial_starts_on = Date.current.advance(days: -5)
        subscription.trial_ends_on = Date.current.advance(days: 5)
      end

      it { is_expected.to eq(10) }
    end
  end

  describe '#trial_days_used' do
    subject { helper.trial_days_used(group) }

    context 'at the beginning of a trial' do
      before do
        subscription.trial_starts_on = Date.current
        subscription.trial_ends_on = Date.current.advance(days: 30)
      end

      it { is_expected.to eq(0) }
    end

    context 'in the middle of a trial' do
      it { is_expected.to eq(15) }
    end

    context 'at the end of a trial' do
      before do
        subscription.trial_starts_on = Date.current.advance(days: -30)
        subscription.trial_ends_on = Date.current
      end

      it { is_expected.to eq(30) }
    end
  end

  describe '#trial_percentage_complete' do
    subject { helper.trial_percentage_complete(group) }

    context 'at the beginning of a trial' do
      before do
        subscription.trial_starts_on = Date.current
        subscription.trial_ends_on = Date.current.advance(days: 30)
      end

      it { is_expected.to eq(0.0) }
    end

    context 'in the middle of a trial' do
      it { is_expected.to eq(50.0) }
    end

    context 'at the end of a trial' do
      before do
        subscription.trial_starts_on = Date.current.advance(days: -30)
        subscription.trial_ends_on = Date.current
      end

      it { is_expected.to eq(100.0) }
    end
  end
end
