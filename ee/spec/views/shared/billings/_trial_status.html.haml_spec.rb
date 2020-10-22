# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'shared/billings/_trial_status.html.haml' do
  include ApplicationHelper

  let_it_be(:group) { create(:group) }
  let(:plan) { nil }
  let(:trial_ends_on) { nil }
  let(:trial) { false }

  before do
    create(:gitlab_subscription, namespace: group, hosted_plan: plan, trial_ends_on: trial_ends_on, trial: trial)
  end

  context 'when not eligible for trial' do
    it 'offers to learn more about plans' do
      render 'shared/billings/trial_status', namespace: group
      expect(rendered).to have_content("Learn more about each plan by visiting our")
    end
  end

  context 'when trial active' do
    let(:trial_ends_on) { Date.tomorrow }
    let(:trial) { true }

    context 'with a gold trial' do
      let(:plan) { create(:gold_plan, title: 'Gold') }

      it 'displays expiry date and Gold' do
        render 'shared/billings/trial_status', namespace: group

        expect(rendered).to have_content("Your GitLab.com Gold trial will expire after #{trial_ends_on}. You can retain access to the Gold features by upgrading below.")
      end
    end

    context 'with a silver trial' do
      let(:plan) { create(:gold_plan, title: 'Silver') }

      it 'displays expiry date and Silver' do
        render 'shared/billings/trial_status', namespace: group

        expect(rendered).to have_content("Your GitLab.com Silver trial will expire after #{trial_ends_on}. You can retain access to the Silver features by upgrading below.")
      end
    end
  end

  context 'when trial expired' do
    let(:plan) { create(:free_plan) }
    let(:trial_ends_on) { Date.yesterday }

    it 'displays the date is expired' do
      render 'shared/billings/trial_status', namespace: group

      expect(rendered).to have_content("Your GitLab.com trial expired on #{trial_ends_on}")
    end
  end

  context 'when eligible for trial' do
    before do
      allow(::Gitlab).to receive(:com?).and_return(true)
    end

    it 'offers a trial' do
      render 'shared/billings/trial_status', namespace: group

      expect(rendered).to have_content("start a free 30-day trial of GitLab.com Gold")
    end
  end
end
