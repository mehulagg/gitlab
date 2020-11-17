# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Plan do
  describe '#paid?' do
    subject { plan.paid? }

    Plan.default_plans.each do |plan|
      context "when '#{plan}'" do
        let(:plan) { build("#{plan}_plan".to_sym) }

        it { is_expected.to be_falsey }
      end
    end

    Plan::PAID_HOSTED_PLANS.each do |plan|
      context "when '#{plan}'" do
        let(:plan) { build("#{plan}_plan".to_sym) }

        it { is_expected.to be_truthy }
      end
    end
  end

  describe '::PLANS_ELIGIBLE_FOR_TRIAL' do
    subject { ::Plan::PLANS_ELIGIBLE_FOR_TRIAL }

    it { is_expected.to eq(%w[default free]) }
  end
end
