# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::ProjectTemplate do
  describe '.all' do
    let(:enterprise_templates) { %w[hipaa_audit_protocol] }

    context 'when `enterprise_templates` feature is not licensed' do
      before do
        stub_licensed_features(enterprise_templates: false)
      end

      it 'does not contain enterprise project templates' do
        expect(described_class.all.map(&:name)).not_to include(*enterprise_templates)
      end
    end

    context 'when `enterprise_templates` feature is licensed' do
      before do
        stub_licensed_features(enterprise_templates: true)
      end

      it 'contains enterprise project templates' do
        expect(described_class.all.map(&:name)).to include(*enterprise_templates)
      end
    end
  end
end
