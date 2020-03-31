# frozen_string_literal: true

require 'spec_helper'

describe Plan do
  describe '#default?' do
    subject { plan.default? }

    Plan::DEFAULT_PLANS.each do |plan|
      context "when '#{plan}'" do
        let(:plan) { build("#{plan}_plan".to_sym) }

        it { is_expected.to be_truthy }
      end
    end

    Plan::PAID_HOSTED_PLANS.each do |plan|
      context "when '#{plan}'" do
        let(:plan) { build("#{plan}_plan".to_sym) }

        it { is_expected.to be_falsey }
      end
    end
  end

  describe '#paid?' do
    subject { plan.paid? }

    Plan::DEFAULT_PLANS.each do |plan|
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
end
