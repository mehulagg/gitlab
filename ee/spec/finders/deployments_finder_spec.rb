# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DeploymentsFinder do
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:prod) { create(:environment, project: project, name: "prod") }
  let_it_be(:dev) { create(:environment, project: project, name: "dev") }
  let_it_be(:other_project) { create(:project, :repository) }
  let_it_be(:start_time) { DateTime.new(2017) }
  let_it_be(:end_time) { DateTime.new(2019) }

  def make_deployment(finished_at, env)
    create(:deployment,
           status: :success,
           project: project,
           environment: env,
           finished_at: finished_at)
  end

  let_it_be(:deployment_2016) { make_deployment(DateTime.new(2016), prod) }
  let_it_be(:deployment_2017) { make_deployment(DateTime.new(2017), prod) }
  let_it_be(:deployment_2018) { make_deployment(DateTime.new(2018), prod) }
  let_it_be(:dev_deployment_2018) { make_deployment(DateTime.new(2018), dev) }
  let_it_be(:deployment_2019) { make_deployment(DateTime.new(2019), prod) }
  let_it_be(:deployment_2020) { make_deployment(DateTime.new(2020), prod) }

  describe '#execute' do
    it 'returns successful deployments for the given project and datetime range' do
      travel_to(start_time) do
        create(:deployment, status: :running, project: project, environment: prod)
        create(:deployment, status: :failed, project: project, environment: prod)
        create(:deployment, status: :canceled, project: project, environment: prod)
        create(:deployment, status: :skipped, project: project, environment: prod)
        create(:deployment, status: :success, project: other_project, environment: prod)
        create(:deployment, status: :success, project: other_project, environment: prod)
      end

      expect(described_class.new(
        project: project,
        environment_name: prod.name,
        finished_after: start_time,
        finished_before: end_time
      ).execute).to contain_exactly(deployment_2017, deployment_2018)

      expect(described_class.new(
        project: project,
        environment_name: prod.name,
        finished_after: start_time
      ).execute).to contain_exactly(
        deployment_2017,
        deployment_2018,
        deployment_2019,
        deployment_2020
      )

      expect(described_class.new(
        project: project,
        environment_name: dev.name,
        finished_after: start_time
      ).execute).to contain_exactly(dev_deployment_2018)
    end

    context 'when filtering by group' do
      let_it_be(:group) { create(:group) }
      let_it_be(:subgroup) { create(:group, parent: group) }

      let_it_be(:project_in_group) { create(:project, :repository, group: group) }
      let_it_be(:project_in_subgroup) { create(:project, :repository, group: subgroup) }

      let_it_be(:deployment_in_group) { create(:deployment, status: :success, project: project_in_group) }
      let_it_be(:deployment_in_subgroup) { create(:deployment, status: :success, project: project_in_subgroup) }

      subject { described_class.new(group: group).execute }

      it 'returns all deployments within a group and its subgroups' do
        expect(subject).to match_array([deployment_in_group, deployment_in_subgroup])
      end
    end
  end
end
