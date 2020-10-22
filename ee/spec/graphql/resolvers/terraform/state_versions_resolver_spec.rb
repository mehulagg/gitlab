# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Terraform::StateVersionsResolver do
  include GraphqlHelpers

  it { expect(described_class.type).to eq(Types::Terraform::StateVersionType) }
  it { expect(described_class.null).to be_truthy }

  describe '#resolve' do
    let_it_be(:state, reload: true) { create(:terraform_state) }
    let_it_be(:version1) { create(:terraform_state_version, terraform_state: state, version: 1) }
    let_it_be(:version2) { create(:terraform_state_version, terraform_state: state, version: 2) }
    let_it_be(:other_version) { create(:terraform_state_version) }

    let(:user) { create(:user, maintainer_projects: [state.project]) }
    let(:feature_available) { true }
    let(:ctx) { Hash(current_user: user) }

    subject { resolve(described_class, obj: state, ctx: ctx) }

    before do
      stub_licensed_features(terraform_state_history: feature_available)
    end

    it 'returns versions associated with the state' do
      expect(subject).to eq([version2, version1])
    end

    context 'feature is not available' do
      let(:feature_available) { false }

      it { is_expected.to be_empty }
    end

    context 'user does not have permission' do
      let(:user) { create(:user) }

      it { is_expected.to be_empty }
    end
  end
end
