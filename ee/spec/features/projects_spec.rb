# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Project', :js, quarantine: 'https://gitlab.com/gitlab-org/gitlab/-/issues/222234' do
  describe 'when creating from group template' do
    let(:user) { create(:user) }
    let(:group) { create(:group, name: 'parent-group') }
    let(:template_subgroup) { create(:group, parent: group, name: 'template-subgroup') }
    let(:other_subgroup) { create(:group, parent: group, name: 'other-subgroup') }
    let(:template) { create(:project, namespace: template_subgroup) }

    before do
      stub_licensed_features(custom_project_templates: true)
      group.add_owner(user)
      group.update!(custom_project_templates_group_id: template_subgroup.id)
      sign_in user
    end

    it "defaults to correct namespace" do
      visit new_project_path
      find('#create-from-template-tab').click
      find('.custom-group-project-templates-tab').click
      find("label[for=#{template.name}]").click

      expect(find('.js-select-namespace')).to have_content group.name
    end

    it "uses supplied namespace" do
      visit new_project_path(namespace_id: other_subgroup.id)
      find('#create-from-template-tab').click
      find('.custom-group-project-templates-tab').click
      find("label[for=#{template.name}]").click

      expect(find('.js-select-namespace')).to have_content other_subgroup.name
    end
  end
end
