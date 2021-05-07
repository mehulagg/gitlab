# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ComplianceManagement::Framework do
  context 'validation' do
    let_it_be(:framework) { create(:compliance_framework) }

    subject { framework }

    it { is_expected.to validate_uniqueness_of(:namespace_id).scoped_to(:name) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
    it { is_expected.to validate_length_of(:description).is_at_most(255) }
    it { is_expected.to validate_length_of(:color).is_at_most(10) }
    it { is_expected.to validate_presence_of(:regulated) }
    it { is_expected.to validate_length_of(:pipeline_configuration_full_path).is_at_most(255) }
  end

  describe 'color' do
    context 'with whitespace' do
      subject { create(:compliance_framework, color: ' #ABC123 ')}

      it 'strips whitespace' do
        expect(subject.color).to eq('#ABC123')
      end
    end
  end

  describe '.find_or_create_legacy_default_framework' do
    let_it_be(:group) { create(:group) }
    let_it_be(:project_1) { create(:project, group: group) }
    let_it_be(:project_2) { create(:project, group: group) }
    let_it_be(:sox_framework) { create(:compliance_framework_project_setting, :sox, project: project_1).compliance_management_framework }

    shared_examples 'framework sharing on the group level' do
      it 'shares the same compliance framework on the group level' do
        framework = described_class.find_or_create_legacy_default_framework(project_2, :sox)

        expect(framework).to eq(sox_framework)
      end
    end

    it_behaves_like 'framework sharing on the group level'

    context 'when not "important" attributes differ' do
      before do
        sox_framework.update!(color: '#ccc')
      end

      it_behaves_like 'framework sharing on the group level'
    end

    context 'when the framework does no exist' do
      it 'creates the new framework record' do
        expect do
          described_class.find_or_create_legacy_default_framework(project_2, :gdpr)
        end.to change { ComplianceManagement::Framework.where(namespace: group).count }.from(1).to(2)
      end
    end

    context 'when creating an unknown legacy framework' do
      it 'raises error' do
        expect { described_class.find_or_create_legacy_default_framework(project_2, :unknown) }.to raise_error(KeyError)
      end
    end
  end
end
