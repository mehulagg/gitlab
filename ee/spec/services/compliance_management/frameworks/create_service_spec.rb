# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ComplianceManagement::Frameworks::CreateService do
  let_it_be(:namespace) { create(:namespace) }
  let(:params) do
    {
      name: 'GDPR',
      description: 'The EUs data protection directive',
      color: '#abc123',
      pipeline_configuration_full_path: 'compliance/.gitlab-ci.yml'
    }
  end

  context 'custom_compliance_frameworks is disabled' do
    before do
      stub_licensed_features(custom_compliance_frameworks: false)
    end

    subject { described_class.new(namespace: namespace, params: params, current_user: namespace.owner) }

    it 'does not create a new compliance framework' do
      expect { subject.execute }.not_to change { ComplianceManagement::Framework.count }
    end

    it 'responds with an error message' do
      expect(subject.execute.message).to eq('Not permitted to create framework')
    end
  end

  context 'custom_compliance_frameworks is enabled' do
    before do
      stub_licensed_features(custom_compliance_frameworks: true)
    end

    context 'namespace has a parent' do
      let_it_be(:namespace) { create(:namespace, :with_hierarchy) }
      let(:descendant) { namespace.descendants.first }

      subject { described_class.new(namespace: descendant, params: params, current_user: namespace.owner) }

      it 'responds with a successful service response' do
        expect(subject.execute.success?).to be true
      end

      it 'creates the new framework in the root namespace' do
        expect(subject.execute.payload[:framework].namespace).to eq(namespace)
      end
    end

    context 'when using invalid parameters' do
      subject { described_class.new(namespace: namespace, params: params.except(:name), current_user: namespace.owner) }

      let(:response) { subject.execute }

      it 'responds with an error service response' do
        expect(response.success?).to eq false
        expect(response.payload.messages[:name]).to contain_exactly "can't be blank"
      end
    end

    context 'when creating a compliance framework for a namespace that current_user is not the owner of' do
      subject { described_class.new(namespace: namespace, params: params, current_user: create(:user)) }

      it 'responds with an error service response' do
        expect(subject.execute.success?).to be false
      end

      it 'does not create a new compliance framework' do
        expect { subject.execute }.not_to change { ComplianceManagement::Framework.count }
      end
    end

    context 'when using parameters for a valid compliance framework' do
      subject { described_class.new(namespace: namespace, params: params, current_user: namespace.owner) }

      it 'creates a new compliance framework' do
        expect { subject.execute }.to change { ComplianceManagement::Framework.count }.by(1)
      end

      it 'responds with a successful service response' do
        expect(subject.execute.success?).to be true
      end

      it 'has the expected attributes' do
        framework = subject.execute.payload[:framework]

        expect(framework.name).to eq('GDPR')
        expect(framework.description).to eq('The EUs data protection directive')
        expect(framework.color).to eq('#abc123')
        expect(framework.pipeline_configuration_full_path).to eq('compliance/.gitlab-ci.yml')
      end
    end
  end
end
