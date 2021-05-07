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

  context 'group has compliance frameworks' do
    let_it_be(:framework) { create(:compliance_framework, namespace: group, name: 'Custom framework 23') }

    it 'includes a dropdown including that framework' do
      render

      expect(rendered).to match /Custom framework 23/
    end

    it 'does not include warning message' do
      render

      expect(rendered).not_to match /Customizable by owners./
    end

    it 'contains the dropdown' do
      render

      expect(rendered).to have_css('select[id=project_compliance_framework_setting_attributes_framework]')
      expect(rendered).not_to have_css('select[id=project_compliance_framework_setting_attributes_framework][disabled="disabled"]')
    end

    context 'user is group maintainer' do
      let_it_be(:maintainer) { create(:user) }

      before do
        group.add_maintainer(maintainer)
        allow(view).to receive(:current_user).and_return(maintainer)
      end

      it 'includes warning message' do
        render

        expect(rendered).to match /Customizable by owners./
      end

      it 'disables the dropdown' do
        render

        expect(rendered).to have_css('input[id=project_compliance_framework_setting_attributes_framework][disabled="disabled"]')
      end
    end
  end

  context 'group has no compliance frameworks' do
    before do
      group.compliance_management_frameworks.delete_all
    end

    it 'shows a notification' do
      render

      expect(rendered).to match /No compliance frameworks are in use. Create one from the .* section in Group Settings./
    end
  end
end
