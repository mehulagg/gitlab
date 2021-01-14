# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IssuablesDescriptionTemplatesHelper do
  include_context 'project issuable templates context'

  describe '#issuable_templates' do
    let_it_be(:inherited_from) { nil }
    let_it_be(:user) { create(:user) }
    let_it_be(:parent_group) { create(:group) }
    let_it_be(:project) { create(:project, :custom_repo, files: issuable_template_files) }
    let_it_be(:group_member) { create(:group_member, :developer, group: parent_group, user: user) }
    let_it_be(:project_member) { create(:project_member, :developer, user: user, project: project) }

    context 'when project has no parent group' do
      it_behaves_like 'project issuable templates'
    end

    context 'when project has parent group' do
      before do
        project.update!(group: parent_group)
      end

      context 'when project parent group does not have a file template project' do
        it_behaves_like 'project issuable templates'
      end

      context 'when project parent group has a file template project' do
        let_it_be(:file_template_project) { create(:project, :custom_repo, group: parent_group, files: issuable_template_files) }
        let_it_be(:group) { create(:group, parent: parent_group) }
        let_it_be(:project) { create(:project, :custom_repo, group: group, files: issuable_template_files) }

        before do
          project.update!(group: group)
          parent_group.update_columns(file_template_project_id: file_template_project.id)
        end

        it_behaves_like 'project issuable templates'
      end
    end
  end

  describe '#service_desk_templates_names' do
    context 'with project templates' do
      let(:templates) {
        {
          "Project Templates" => [
            { name: "another_issue_template", id: "another_issue_template", project_id: 25 },
            { name: "custom_issue_template", id: "custom_issue_template", project_id: 25 }
          ],
          "Instance" => [
            { name: "first_issue_issue_template", id: "first_issue_issue_template", project_id: 20 },
            { name: "second_instance_issue_template", id: "second_instance_issue_template", project_id: 20 }
          ]
        }
      }

      it 'returns project templates only' do
        allow(helper).to receive(:issuable_templates).and_return(templates)

        expect(helper.service_desk_templates_names(Issue.new)).to eq(%w[another_issue_template custom_issue_template])
      end
    end
  end

  context 'without project templates' do
    let(:templates) {
      {
        "" => [
          { name: "another_issue_template", id: "another_issue_template", project_id: 25 },
          { name: "custom_issue_template", id: "custom_issue_template", project_id: 25 }
        ],
        "Instance" => [
          { name: "first_issue_issue_template", id: "first_issue_issue_template", project_id: 20 },
          { name: "second_instance_issue_template", id: "second_instance_issue_template", project_id: 20 }
        ]
      }
    }

    it 'returns empty array' do
      allow(helper).to receive(:issuable_templates).and_return(templates)

      expect(helper.service_desk_templates_names(Issue.new)).to eq([])
    end
  end

  context 'templates as empty hash' do
    let(:templates) { {} }

    it 'returns empty array' do
      allow(helper).to receive(:issuable_templates).and_return(templates)

      expect(helper.service_desk_templates_names(Issue.new)).to eq([])
    end
  end

  context 'templates is nil' do
    let(:templates) { nil }

    it 'returns empty array' do
      allow(helper).to receive(:issuable_templates).and_return(templates)

      expect(helper.service_desk_templates_names(Issue.new)).to eq([])
    end
  end
end
