# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'projects/edit.html.haml' do
  let_it_be(:group) { create(:group) }
  let_it_be(:group_owner) { create(:user) }
  let_it_be(:project) { create(:project, namespace: group) }

  before do
    allow(view).to receive(:current_user).and_return(group_owner)
    allow(group_owner).to receive(:can?).and_return(true)
    assign(:project, project)
    stub_licensed_features(custom_compliance_frameworks: true)
  end

  context 'feature enabled' do
    before do
      stub_feature_flags(ff_custom_compliance_frameworks: true)
    end

    context 'group has compliance frameworks' do
      let_it_be(:framework) { create(:compliance_framework, namespace: group, name: 'Custom framework 23') }

      it 'includes a dropdown including that framework' do
        render

        expect(rendered).to match /Custom framework 23/
      end
    end

    context 'group has no compliance frameworks' do
      before do
        group.compliance_management_frameworks.delete_all
      end

      it 'shows a notification' do
        render

        expect(rendered).to match /No compliance frameworks are in use. Create one using the GraphQL API./
      end
    end
  end

  context 'feature disabled' do
    before do
      stub_feature_flags(ff_custom_compliance_frameworks: false)
    end

    it 'includes a dropdown including only the hard-coded frameworks' do
      render

      expect(rendered).to match /GDPR/
      expect(rendered).to match /HIPAA/
      expect(rendered).to match /PCI-DSS/
      expect(rendered).to match /SOC 2/
      expect(rendered).to match /SOX/
    end
  end
end
