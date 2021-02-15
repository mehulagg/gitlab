# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DeploymentsFinder do
  context 'when filtering by group' do
    let_it_be(:group) { create(:group) }
    let_it_be(:subgroup) { create(:group, parent: group) }

    let_it_be(:project_in_group) { create(:project, :repository, group: group) }
    let_it_be(:project_in_subgroup) { create(:project, :repository, group: subgroup) }

    let_it_be(:deployment_in_group) { create(:deployment, status: :success, project: project_in_group) }
    let_it_be(:deployment_in_subgroup) { create(:deployment, status: :success, project: project_in_subgroup) }

    subject { described_class.new(group: group).execute }

    it { is_expected.to match_array([deployment_in_group, deployment_in_subgroup]) }
  end
end
