# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NamespacePolicy do
  let(:owner) { build_stubbed(:user) }
  let(:namespace) { build_stubbed(:namespace, owner: owner) }
  let(:owner_permissions) { [:create_projects, :admin_namespace, :read_namespace] }

  subject { described_class.new(current_user, namespace) }

  context 'auditor' do
    let(:current_user) { build_stubbed(:user, :auditor) }

    context 'owner' do
      let(:namespace) { build_stubbed(:namespace, owner: current_user) }

      it { is_expected.to be_allowed(*owner_permissions) }
    end

    context 'non-owner' do
      it { is_expected.to be_disallowed(*owner_permissions) }
    end
  end

  context ':over_storage_limit' do
    let(:current_user) { owner }

    before do
      allow(namespace).to receive(:over_storage_limit?).and_return(over_storage_limit)
    end

    context 'when the namespace has exceeded its storage limit' do
      let(:over_storage_limit) { true }

      it { is_expected.to(be_disallowed(:create_projects)) }
    end

    context 'when the namespace has not exceeded its storage limit' do
      let(:over_storage_limit) { false }

      it { is_expected.to(be_allowed(:create_projects)) }
    end
  end

  it_behaves_like 'update namespace limit policy'
end
