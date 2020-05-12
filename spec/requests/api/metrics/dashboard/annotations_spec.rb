# frozen_string_literal: true

require 'spec_helper'

describe API::Metrics::Dashboard::Annotations do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, :private, :repository, namespace: user.namespace) }
  let_it_be(:environment) { create(:environment, project: project) }
  let(:dashboard) { 'config/prometheus/common_metrics.yml' }
  let(:starting_at) { Time.now.iso8601 }
  let(:ending_at) { 1.hour.from_now.iso8601 }
  let(:params) { attributes_for(:metrics_dashboard_annotation, environment: environment, starting_at: starting_at, ending_at: ending_at, dashboard_path: dashboard)}

  shared_examples 'POST /:source_type/:id/metrics_dashboard/annotations' do |source_type|
    let(:url) { "/#{source_type.pluralize}/#{source.id}/metrics_dashboard/annotations" }

    before do
      project.add_developer(user)
    end

    context "with :source_type == #{source_type.pluralize}" do
      context 'feature flag metrics_dashboard_annotations' do
        context 'is on' do
          before do
            stub_feature_flags(metrics_dashboard_annotations: { enabled: true, thing: project })
          end

          context 'with correct permissions' do
            context 'with valid parameters' do
              it 'creates a new annotation', :aggregate_failures do
                post api(url, user), params: params

                expect(response).to have_gitlab_http_status(:created)
                expect(json_response["#{source_type}_id"]).to eq(source.id)
                expect(json_response['starting_at'].in_time_zone).to eq(starting_at.in_time_zone)
                expect(json_response['ending_at'].in_time_zone).to eq(ending_at.in_time_zone)
                expect(json_response['description']).to eq(params[:description])
                expect(json_response['dashboard_path']).to eq(dashboard)
              end
            end

            context 'with invalid parameters' do
              it 'returns error messsage' do
                post api(url, user), params: { dashboard_path: nil, starting_at: nil, description: nil }

                expect(response).to have_gitlab_http_status(:bad_request)
                expect(json_response['message']).to include({ "starting_at" => ["can't be blank"], "description" => ["can't be blank"], "dashboard_path" => ["can't be blank"] })
              end
            end

            context 'with undeclared params' do
              before do
                params[:undeclared_param] = 'xyz'
              end

              it 'filters out undeclared params' do
                expect(::Metrics::Dashboard::Annotations::CreateService).to receive(:new).with(user, hash_excluding(:undeclared_param))

                post api(url, user), params: params
              end
            end
          end

          context 'without correct permissions' do
            let_it_be(:guest) { create(:user) }

            before do
              project.add_guest(guest)
            end

            it 'returns error messsage' do
              post api(url, guest), params: params

              expect(response).to have_gitlab_http_status(:forbidden)
            end
          end
        end

        context 'is off' do
          before do
            stub_feature_flags(metrics_dashboard_annotations: { enabled: false })
          end

          it 'returns error messsage' do
            post api(url, user), params: params

            expect(response).to have_gitlab_http_status(:not_found)
          end
        end
      end
    end
  end

  describe 'environment' do
    it_behaves_like 'POST /:source_type/:id/metrics_dashboard/annotations', 'environment' do
      let(:source) { environment }
    end
  end

  describe 'group cluster' do
    it_behaves_like 'POST /:source_type/:id/metrics_dashboard/annotations', 'cluster' do
      let_it_be(:group) { create(:group) }
      let_it_be(:cluster) { create(:cluster_for_group, groups: [group]) }

      before do
        group.add_developer(user)
      end

      let(:source) { cluster }
    end
  end

  describe 'project cluster' do
    it_behaves_like 'POST /:source_type/:id/metrics_dashboard/annotations', 'cluster' do
      let_it_be(:cluster) { create(:cluster, projects: [project]) }

      let(:source) { cluster }
    end
  end
end
