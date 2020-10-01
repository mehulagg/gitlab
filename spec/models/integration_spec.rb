# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Integration do
  let_it_be(:group) { create(:group) }
  let_it_be(:subgroup) { create(:group, parent: group) }
  let_it_be(:project_1) { create(:project) }
  let_it_be(:project_2) { create(:project) }
  let_it_be(:project_3) { create(:project) }
  let_it_be(:project_4) { create(:project, group: group) }
  let_it_be(:project_5) { create(:project, group: subgroup) }
  let_it_be(:instance_integration) { create(:jira_service, :instance) }
  let_it_be(:group_integration) { create(:jira_service, group: group, project: nil) }
  let_it_be(:subgroup_integration) { create(:jira_service, group: subgroup, project: nil) }

  before do
    create(:jira_service, project: project_1, inherit_from_id: instance_integration.id)
    create(:jira_service, project: project_2, inherit_from_id: nil)
    create(:slack_service, project: project_3, inherit_from_id: nil)
  end

  describe '.with_custom_integration_for' do
    it 'returns projects with custom integrations' do
      expect(Project.with_custom_integration_for(instance_integration)).to contain_exactly(project_2)
    end
  end

  describe '.without_integration' do
    it 'returns projects without integration' do
      expect(Project.without_integration(instance_integration)).to contain_exactly(project_3, project_4, project_5)
    end
  end

  describe '.belonging_to_group_without_integration' do
    it 'returns projects belonging to group without integration' do
      expect(Project.belonging_to_group_without_integration(group_integration)).to contain_exactly(project_4, project_5)
    end
  end
end
