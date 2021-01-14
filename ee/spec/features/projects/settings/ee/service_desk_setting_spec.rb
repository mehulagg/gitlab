# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Service Desk Setting', :js do
  include IssuablesDescriptionTemplatesHelper

  let_it_be(:issuable_project_template_files) do
    {
      '.gitlab/issue_templates/project-issue-bar.md' => 'Project Issue Template Bar',
      '.gitlab/issue_templates/project-issue-foo.md' => 'Project Issue Template Foo'
    }
  end

  let_it_be(:issuable_group_template_files) do
    {
      '.gitlab/issue_templates/group-issue-bar.md' => 'Group Issue Template Bar',
      '.gitlab/issue_templates/group-issue-foo.md' => 'Group Issue Template Foo'
    }
  end

  let_it_be(:group) { create(:group)}
  let_it_be(:group_template_repo) { create(:project, :custom_repo, group: group, files: issuable_group_template_files) }
  let_it_be(:project) { create(:project, :custom_repo, group: group, files: issuable_project_template_files) }
  let_it_be(:user) { create(:user) }
  let_it_be(:presenter) { project.present(current_user: user) }

  before do
    stub_licensed_features(custom_file_templates_for_namespace: true, custom_file_templates: true)

    project.add_maintainer(user)
    sign_in(user)

    allow(::Gitlab::IncomingEmail).to receive(:enabled?) { true }
    allow(::Gitlab::IncomingEmail).to receive(:supports_wildcard?) { true }

    allow(::Gitlab::ServiceDeskEmail).to receive(:enabled?) { true }
    allow(::Gitlab::ServiceDeskEmail).to receive(:address_for_key) { 'address-suffix@example.com' }

    allow_next_instance_of(Project) do |proj_instance|
      expect(proj_instance).to receive(:present).with(current_user: user).and_return(presenter)
    end

    group.update_columns(file_template_project_id: group_template_repo.id)
    project.reload

    visit edit_project_path(project)
  end

  context 'issue description templates' do
    it 'loads issue description templates from the project only' do
      # issuable_templates returns group issue description templates as well,
      # but we only need project issue description templates for Service Desk
      template_names = issuable_templates(project, 'issues').values.flatten.map { |tpl| tpl[:name] }
      expect(template_names).to match_array(%w[project-issue-bar project-issue-foo group-issue-bar group-issue-foo])

      within('#service-desk-template-select') do
        expect(page).to have_content('project-issue-bar')
        expect(page).to have_content('project-issue-foo')
      end
    end
  end
end
