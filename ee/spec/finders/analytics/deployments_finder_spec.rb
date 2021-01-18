# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DeploymentsFinder do
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :repository, group: group) }
  let_it_be(:prod) { create(:environment, project: project, name: "prod") }
  let_it_be(:dev) { create(:environment, project: project, name: "dev") }
  let_it_be(:other_project) { create(:project, :repository, group: group) }
  let_it_be(:start_time) { DateTime.new(2017) }
  let_it_be(:end_time) { DateTime.new(2019) }

  def make_deployment(finished_at, proj, env)
    create(:deployment,
           status: :success,
           project: proj,
           environment: env,
           finished_at: finished_at)
  end

  let_it_be(:deployment_2016) { make_deployment(DateTime.new(2016), project, prod) }
  let_it_be(:deployment_2017) { make_deployment(DateTime.new(2017), project, prod) }
  let_it_be(:deployment_2018) { make_deployment(DateTime.new(2018), project, prod) }
  let_it_be(:dev_deployment_2018) { make_deployment(DateTime.new(2018), project, dev) }
  let_it_be(:other_deployment_2018) { make_deployment(DateTime.new(2018), other_project, prod) }
  let_it_be(:deployment_2019) { make_deployment(DateTime.new(2019), project, prod) }
  let_it_be(:deployment_2020) { make_deployment(DateTime.new(2020), project, prod) }

  describe '#execute' do
    before do
      travel_to(start_time) do
        create(:deployment, status: :running, project: project, environment: prod)
        create(:deployment, status: :failed, project: project, environment: prod)
        create(:deployment, status: :canceled, project: project, environment: prod)
        create(:deployment, status: :skipped, project: project, environment: prod)
        create(:deployment, status: :success, project: other_project, environment: prod)
        create(:deployment, status: :success, project: other_project, environment: prod)
      end
    end

    it 'returns successful prod deployments between dates' do
      expect(described_class.new(
        project_or_group: project,
        environment_name: prod.name,
        from: start_time,
        to: end_time
      ).execute).to contain_exactly(deployment_2017, deployment_2018)
    end

    it 'returns successful prod deplyoments after start date' do
      expect(described_class.new(
        project_or_group: project,
        environment_name: prod.name,
        from: start_time
      ).execute).to contain_exactly(
        deployment_2017,
        deployment_2018,
        deployment_2019,
        deployment_2020
      )
    end

    it 'returns successful dev deplyoments after start date' do
      expect(described_class.new(
        project_or_group: project,
        environment_name: dev.name,
        from: start_time
      ).execute).to contain_exactly(dev_deployment_2018)
    end

    it 'returns successful deployments across an entire group' do
      expect(described_class.new(
        project_or_group: group,
        environment_name: prod.name,
        from: start_time
      ).execute).to contain_exactly(
        deployment_2017,
        deployment_2018,
        other_deployment_2018,
        deployment_2019,
        deployment_2020
      )
    end

    subject do
      described_class.new(
        project_or_group: group,
        environment_name: prod.name,
        from: start_time
      ).execute
    end

    it 'avoids N+1 queries' do
      control_count = ActiveRecord::QueryRecorder.new { subject }.count
      new_project = create(:project, :repository, group: group)
      create(:deployment, status: :success, project: new_project, environment: prod)

      group.reload

      expect { subject }.not_to exceed_query_limit(control_count)
    end
  end
end
