# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IssuablesDescriptionTemplatesHelper do
  issue_template_files = {
    '.gitlab/issue_templates/issue-bar.md' => 'Issue Template Bar',
    '.gitlab/issue_templates/issue-foo.md' => 'Issue Template Foo',
    '.gitlab/issue_templates/issue-bad.txt' => 'Issue Template Bad',
    '.gitlab/issue_templates/issue-baz.xyz' => 'Issue Template Baz',

    '.gitlab/merge_request_templates/merge_request-bar.md' => 'Merge Request Template Bar',
    '.gitlab/merge_request_templates/merge_request-foo.md' => 'Merge Request Template Foo',
    '.gitlab/merge_request_templates/merge_request-bad.txt' => 'Merge Request Template Bad',
    '.gitlab/merge_request_templates/merge_request-baz.xyz' => 'Merge Request Template Baz'
  }

  RSpec.shared_examples 'project issuable templates' do
    context 'issuable templates' do
      it 'returns only md files as templates', :aggregate_failures do
        expect(project_issuable_templates(project, 'issue')).to eq(expected_templates('issue'))
        expect(project_issuable_templates(project, 'merge_request')).to eq(expected_templates('merge_request'))
      end
    end

    def expected_templates(issuable_type)
      {
        "Project Templates" => [
          { id: "#{issuable_type}-bar", name: "#{issuable_type}-bar", namespace_path: project.namespace.full_path, project_path: project.path },
          { id: "#{issuable_type}-foo", name: "#{issuable_type}-foo", namespace_path: project.namespace.full_path, project_path: project.path }
        ]
      }
    end
  end

  describe '#project_issuable_templates' do
    context 'when project has no parent group' do
      let!(:project) { create(:project, :custom_repo, files: issue_template_files) }

      it_behaves_like 'project issuable templates'
    end

    context 'when project has parent group' do
      let(:group) { create(:group) }
      let!(:project) { create(:project, :custom_repo, group: group, files: issue_template_files) }

      context 'when project parent group does not have a file template project' do
        it_behaves_like 'project issuable templates'
      end

      context 'when project parent group has a file template project' do
        let(:parent_group) { create(:group) }
        let!(:file_template_project) { create(:project, :custom_repo, group: parent_group, files: issue_template_files) }
        let(:group) { create(:group, parent: parent_group) }
        let!(:project) { create(:project, :custom_repo, group: group, files: issue_template_files) }

        before do
          parent_group.update_columns(file_template_project_id: file_template_project.id)
        end

        it_behaves_like 'project issuable templates'
      end
    end
  end
end
