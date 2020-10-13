# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe CleanupDeployAccessLevelsForRemovedGroups do
  let(:namespaces) { table(:namespaces) }
  let(:projects) { table(:projects) }
  let(:groups) { table(:namespaces) }
  let(:project_group_links) { table(:project_group_links) }
  let(:protected_environments) { table(:protected_environments) }
  let(:deploy_access_levels) { table(:protected_environment_deploy_access_levels) }

  it 'removes deploy access levels for removed groups and keeps the rest' do
    namespace = namespaces.create!(name: 'gitlab', path: 'gitlab')
    project = projects.create!(namespace_id: namespace.id)
    protected_environment = protected_environments.create!(project_id: project.id, name: 'production')

    removed_group = namespaces.create!(name: 'removed-group', path: 'removed-group', type: 'Group')
    legit_group = namespaces.create!(name: 'legit-group', path: 'legit-group', type: 'Group')
    project_group_links.create!(project_id: project.id, group_id: legit_group.id)

    deploy_access_level_for_removed_group = deploy_access_levels.create!(protected_environment_id: protected_environment.id, group_id: removed_group.id)
    deploy_access_level_for_legit_group = deploy_access_levels.create!(protected_environment_id: protected_environment.id, group_id: legit_group.id)
    deploy_access_level_for_access_level = deploy_access_levels.create!(protected_environment_id: protected_environment.id, access_level: Gitlab::Access::MAINTAINER)

    expect { migrate! }.to change { deploy_access_levels.count }.from(3).to(2)

    expect(deploy_access_levels.where(protected_environment_id: protected_environment.id))
      .to contain_exactly(deploy_access_level_for_legit_group, deploy_access_level_for_access_level)

    expect(deploy_access_levels.find_by_id(deploy_access_level_for_removed_group.id)).to be_nil
  end
end
