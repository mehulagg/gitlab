# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AlertManagement::HttpIntegration do
  describe 'associations' do
    it { is_expected.to belong_to(:project) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:project) }
    it { is_expected.to validate_inclusion_of(:active).in_array([true, false]) }

    context 'when active in a project' do
      let_it_be(:project) { create(:project) }

      subject { described_class.new(active: true, project_id: project.id) }

      it { is_expected.to validate_uniqueness_of(:endpoint_identifier).scoped_to(:project_id, :active) }
    end

    context 'with name' do
      subject { described_class.new(name: 'DataDog') }

      it { is_expected.to validate_presence_of(:endpoint_identifier) }
    end

    context 'with endpoint_identifier' do
      subject { described_class.new(endpoint_identifier: 'c4421f7c') }

      it { is_expected.to validate_presence_of(:name) }
    end
  end

  describe '#token' do
    let_it_be(:project) { create(:project) }
    let(:active) { true }
    let(:params) { { project: project, active: active } }
    let(:integration) { described_class.new(**params) }

    shared_context 'when active' do
      let(:active) { true }
    end

    shared_context 'when inactive' do
      let(:active) { false }
    end

    shared_context 'when persisted' do
      before do
        integration.save!
        integration.reload
      end
    end

    shared_context 'reset token' do
      before do
        integration.token = ''
        integration.valid?
      end
    end

    shared_context 'assign token' do |token|
      before do
        integration.token = token
        integration.valid?
      end
    end

    shared_examples 'valid token' do
      it { is_expected.to match(/\A\h{32}\z/) }
    end

    shared_examples 'no token' do
      it { is_expected.to be_blank }
    end

    subject { integration.token }

    context 'when active' do
      include_context 'when active'

      context 'when resetting' do
        let!(:previous_token) { integration.token }

        include_context 'reset token'

        it_behaves_like 'valid token'

        it { is_expected.not_to eq(previous_token) }
      end

      context 'when assigning' do
        include_context 'assign token', 'random token'

        it_behaves_like 'valid token'
      end
    end

    context 'when inactive' do
      include_context 'when inactive'

      context 'when resetting' do
        let!(:previous_token) { integration.token }

        include_context 'reset token'

        it_behaves_like 'no token'
      end
    end

    context 'when persisted' do
      include_context 'when persisted'

      it_behaves_like 'valid token'
    end
  end
end
