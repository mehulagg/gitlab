# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DeploymentsFinder do
  subject { described_class.new(params).execute }

  context 'at group scope' do
    let_it_be(:group) { create(:group) }
    let_it_be(:subgroup) { create(:group, parent: group) }

    let(:group_project_1) { create(:project, :public, :test_repo, group: group) }
    let(:group_project_2) { create(:project, :public, :test_repo, group: group) }
    let(:subgroup_project_1) { create(:project, :public, :test_repo, group: subgroup) }
    let(:base_params) { { group: group } }

    describe 'ordering' do
      using RSpec::Parameterized::TableSyntax

      let(:params) { { **base_params, order_by: order_by, sort: sort } }

      let!(:group_project_1_deployment) { create(:deployment, :success, project: group_project_1, iid: 11, ref: 'master', created_at: 2.days.ago, updated_at: Time.now, finished_at: Time.now) }
      let!(:group_project_2_deployment) { create(:deployment, :success, project: group_project_2, iid: 12, ref: 'feature', created_at: 1.day.ago, updated_at: 2.hours.ago, finished_at: 2.hours.ago) }
      let!(:subgroup_project_1_deployment) { create(:deployment, :success, project: subgroup_project_1, iid: 8, ref: 'video', created_at: Time.now, updated_at: 1.hour.ago, finished_at: 1.hour.ago) }

      where(:order_by, :sort) do
        'created_at'  | 'asc'
        'created_at'  | 'desc'
        'id'          | 'asc'
        'id'          | 'desc'
        'iid'         | 'asc'
        'iid'         | 'desc'
        'ref'         | 'asc'
        'ref'         | 'desc'
        'updated_at'  | 'asc'
        'updated_at'  | 'desc'
        'finished_at' | 'asc'
        'finished_at' | 'desc'
        'invalid'     | 'asc'
        'iid'         | 'err'
      end

      with_them do
        it 'returns the deployments unordered' do
          expect(subject.to_a).to contain_exactly(group_project_1_deployment,
                                                  group_project_2_deployment,
                                                  subgroup_project_1_deployment)
        end
      end
    end

    it 'avoids N+1 queries' do
      execute_queries = -> { described_class.new({ group: group }).execute.first }
      control_count = ActiveRecord::QueryRecorder.new { execute_queries }.count

      new_project = create(:project, :repository, group: group)
      new_env = create(:environment, project: new_project, name: "production")
      create_list(:deployment, 2, status: :success, project: new_project, environment: new_env)
      group.reload

      expect { execute_queries }.not_to exceed_query_limit(control_count)
    end
  end
end
