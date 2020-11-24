# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NamespaceOnboardingAction do
  let(:namespace) { build(:namespace) }

  it { is_expected.to belong_to :namespace }

  describe '.completed?' do
    let(:action) { :subscription_created }
    let(:build_namespace_onboarding_action) { create(:namespace_onboarding_action, namespace: namespace, action: action) }

    subject { described_class.completed?(namespace, action) }

    context 'when action got created' do
      before do
        build_namespace_onboarding_action
      end

      it { is_expected.to eq(true) }
    end

    context 'when action has not been created' do
      it { is_expected.to eq(false) }
    end
  end

  describe '.create_action' do
    let(:action) { :subscription_created }

    subject { described_class.create_action(namespace, action) }

    it 'creates the action for the namespace' do
      expect { subject }.to change {
        NamespaceOnboardingAction.where(namespace: namespace, action: action).count
      }.by(1)
    end

    it 'creates the action for the namespace just once' do
      expect { subject }.to change {
        NamespaceOnboardingAction.where(namespace: namespace, action: action).count
      }.by(1)

      expect { subject }.to change {
        NamespaceOnboardingAction.where(namespace: namespace, action: action).count
      }.by(0)
    end
  end
end
