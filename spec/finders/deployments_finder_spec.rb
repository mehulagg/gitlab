# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DeploymentsFinder do
  subject { described_class.new(params).execute }

  let_it_be(:project) { create(:project, :public, :test_repo) }
  let(:params) { { project: project } }

  describe "#execute" do
    it 'returns all deployments by default' do
      deployments = create_list(:deployment, 2, :success, project: project)
      is_expected.to match_array(deployments)
    end

    context 'when project is missing' do
      let(:params) { {} }

      it 'returns nothing' do
        is_expected.to eq([])
      end
    end

    describe 'filtering' do
      context 'when updated_at filters are specified' do
        let(:params) { { project: project, updated_before: 1.day.ago, updated_after: 3.days.ago } }
        let!(:deployment_1) { create(:deployment, :success, project: project, updated_at: 2.days.ago) }
        let!(:deployment_2) { create(:deployment, :success, project: project, updated_at: 4.days.ago) }
        let!(:deployment_3) { create(:deployment, :success, project: project, updated_at: 1.hour.ago) }

        it 'returns deployments with matched updated_at' do
          is_expected.to match_array([deployment_1])
        end
      end

      context 'when the environment name is specified' do
        let!(:environment1) { create(:environment, project: project) }
        let!(:environment2) { create(:environment, project: project) }
        let!(:deployment1) do
          create(:deployment, project: project, environment: environment1)
        end

        let!(:deployment2) do
          create(:deployment, project: project, environment: environment2)
        end

        let(:params) { { project: project, environment: environment1.name } }

        it 'returns deployments for the given environment' do
          is_expected.to match_array([deployment1])
        end
      end

      context 'when the deployment status is specified' do
        let!(:deployment1) { create(:deployment, :success, project: project) }
        let!(:deployment2) { create(:deployment, :failed, project: project) }
        let(:params) { { project: project, status: 'success' } }

        it 'returns deployments for the given environment' do
          is_expected.to match_array([deployment1])
        end
      end

      context 'when using an invalid deployment status' do
        let(:params) { { project: project, status: 'kittens' } }

        it 'raises ArgumentError' do
          expect { subject }.to raise_error(ArgumentError)
        end
      end

      context 'when filtering by finished time' do
        let!(:deployment_1) { create(:deployment, :success, project: project, finished_at: 2.days.ago) }
        let!(:deployment_2) { create(:deployment, :success, project: project, finished_at: 4.days.ago) }
        let!(:deployment_3) { create(:deployment, :success, project: project, finished_at: 5.hours.ago) }

        context 'when filtering by finished_after and finished_before' do
          let(:params) { { project: project, finished_after: 3.days.ago, finished_before: 1.day.ago } }

          it { is_expected.to match_array([deployment_1]) }
        end

        context 'when the finished_before parameter is missing' do
          let(:params) { { project: project, finished_after: 3.days.ago } }

          it { is_expected.to match_array([deployment_1, deployment_3]) }
        end

        context 'when finished_after is missing' do
          let(:params) { { project: project, finished_before: 1.day.ago } }

          it 'does not apply any filters on finished time' do
            is_expected.to match_array([deployment_1, deployment_2, deployment_3])
          end
        end
      end
    end

    describe 'ordering' do
      using RSpec::Parameterized::TableSyntax

      let(:params) { { project: project, order_by: order_by, sort: sort } }

      let!(:deployment_1) { create(:deployment, :success, project: project, iid: 11, ref: 'master', created_at: 2.days.ago, updated_at: Time.now, finished_at: 3.hours.ago) }
      let!(:deployment_2) { create(:deployment, :success, project: project, iid: 12, ref: 'feature', created_at: 1.day.ago, updated_at: 2.hours.ago, finished_at: 1.hour.ago) }
      let!(:deployment_3) { create(:deployment, :success, project: project, iid: 8, ref: 'video', created_at: Time.now, updated_at: 1.hour.ago, finished_at: 2.hours.ago) }

      where(:order_by, :sort, :ordered_deployments) do
        'created_at'  | 'asc'  | [:deployment_1, :deployment_2, :deployment_3]
        'created_at'  | 'desc' | [:deployment_3, :deployment_2, :deployment_1]
        'id'          | 'asc'  | [:deployment_1, :deployment_2, :deployment_3]
        'id'          | 'desc' | [:deployment_3, :deployment_2, :deployment_1]
        'iid'         | 'asc'  | [:deployment_3, :deployment_1, :deployment_2]
        'iid'         | 'desc' | [:deployment_2, :deployment_1, :deployment_3]
        'ref'         | 'asc'  | [:deployment_2, :deployment_1, :deployment_3]
        'ref'         | 'desc' | [:deployment_3, :deployment_1, :deployment_2]
        'updated_at'  | 'asc'  | [:deployment_2, :deployment_3, :deployment_1]
        'updated_at'  | 'desc' | [:deployment_1, :deployment_3, :deployment_2]
        'finished_at' | 'asc'  | [:deployment_1, :deployment_3, :deployment_2]
        'finished_at' | 'desc' | [:deployment_2, :deployment_3, :deployment_1]
        'invalid'     | 'asc'  | [:deployment_1, :deployment_2, :deployment_3]
        'iid'         | 'err'  | [:deployment_3, :deployment_1, :deployment_2]
      end

      with_them do
        it 'returns the deployments ordered' do
          expect(subject).to eq(ordered_deployments.map { |name| public_send(name) })
        end
      end
    end

    describe 'transform `created_at` sorting to `id` sorting' do
      let(:params) { { project: project, order_by: 'created_at', sort: 'asc' } }

      it 'sorts by only one column' do
        expect(subject.order_values.size).to eq(1)
      end

      it 'sorts by `id`' do
        expect(subject.order_values.first.to_sql).to eq(Deployment.arel_table[:id].asc.to_sql)
      end
    end

    describe 'tie-breaker for `updated_at` sorting' do
      let(:params) { { project: project, order_by: 'updated_at', sort: 'asc' } }

      it 'sorts by two columns' do
        expect(subject.order_values.size).to eq(2)
      end

      it 'adds `id` sorting as the second order column' do
        order_value = subject.order_values[1]

        expect(order_value.to_sql).to eq(Deployment.arel_table[:id].desc.to_sql)
      end

      it 'uses the `id DESC` as tie-breaker when ordering' do
        updated_at = Time.now

        deployment_1 = create(:deployment, :success, project: project, updated_at: updated_at)
        deployment_2 = create(:deployment, :success, project: project, updated_at: updated_at)
        deployment_3 = create(:deployment, :success, project: project, updated_at: updated_at)

        expect(subject).to eq([deployment_3, deployment_2, deployment_1])
      end
    end
  end
end
