# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Security::NetworkPoliciesController do
  let_it_be(:group) { create(:group) }
  let_it_be(:user) { create(:user) }

  let_it_be(:project) { create(:project, :public, :repository, group: group) }
  let_it_be(:environment) { create(:environment, :with_review_app, project: project) }

  let_it_be(:action_params) { { project_id: project, namespace_id: project.namespace, environment_id: environment.id } }

  let_it_be(:manifest) do
    <<~POLICY
      apiVersion: networking.k8s.io/v1
      kind: NetworkPolicy
      metadata:
        name: example-name
        namespace: example-namespace
      spec:
        podSelector:
          matchLabels:
            role: db
        policyTypes:
        - Ingress
        ingress:
        - from:
          - namespaceSelector:
              matchLabels:
                project: myproject
    POLICY
  end

  shared_examples 'CRUD service errors' do
    context 'with an error service response' do
      before do
        allow(service).to receive(:execute) { ServiceResponse.error(http_status: :bad_request, message: 'error') }
      end

      it 'responds with bad_request' do
        subject

        expect(response).to have_gitlab_http_status(:bad_request)
        expect(response.body).to eq('{"payload":{},"error":"error"}')
      end
    end
  end

  before do
    stub_licensed_features(threat_monitoring: true)

    sign_in(user)
  end

  describe 'GET #summary' do
    subject { get :summary, params: action_params, format: :json }

    let_it_be(:kubernetes_namespace) { environment.deployment_namespace }

    context 'with authorized user' do
      before do
        group.add_developer(user)
      end

      context 'with prometheus configured' do
        let(:adapter) { double("configured?" => true, "can_query?" => true) }

        before do
          allow_next_instance_of(Gitlab::Prometheus::Adapter) do |instance|
            allow(instance).to receive(:prometheus_adapter) { adapter }
          end
        end

        it 'returns network policies summary' do
          freeze_time do
            expect(adapter).to(
              receive(:query)
                .with(:packet_flow, kubernetes_namespace, "minute", 1.hour.ago.to_s, Time.current.to_s)
                .and_return({ success: true, data: { ops_rate: [[Time.zone.at(0).to_i, 10]], ops_total: 10 } })
            )
            subject
          end

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response['ops_total']).to equal(10)
          expect(json_response['ops_rate']).to eq([[0, 10]])
        end

        context 'with additional parameters' do
          let(:action_params) do
            {
              project_id: project, namespace_id: project.namespace, environment_id: environment,
              interval:  "day", from: Time.zone.at(0), to: Time.zone.at(100)
            }
          end

          it 'queries with requested arguments' do
            expect(adapter).to(
              receive(:query)
                .with(:packet_flow, kubernetes_namespace, "day", Time.zone.at(0).to_s, Time.zone.at(100).to_s)
                .and_return({ success: true, data: {} })
            )
            subject
          end
        end

        context 'with invalid Time range' do
          let(:action_params) do
            {
              project_id: project, namespace_id: project.namespace, environment_id: environment,
              from: "not a time", to: "not a time"
            }
          end

          it 'queries with default arguments' do
            freeze_time do
              expect(adapter).to(
                receive(:query)
                  .with(:packet_flow, kubernetes_namespace, "minute", 1.hour.ago.to_s, Time.current.to_s)
                  .and_return({ success: true, data: {} })
              )
              subject
            end
          end
        end

        context 'with nil results' do
          it 'responds with accepted' do
            allow(adapter).to receive(:query).and_return(nil)
            subject

            expect(response).to have_gitlab_http_status(:accepted)
          end
        end
      end

      context 'without prometheus configured' do
        it 'returns not found' do
          subject

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end

      it 'sets a polling interval header' do
        subject

        expect(response.headers['Poll-Interval']).to eq('5000')
      end
    end

    context 'with unauthorized user' do
      it 'returns unauthorized' do
        subject

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end
  end

  describe 'GET #index' do
    subject { get :index, params: action_params, format: :json }

    context 'with authorized user' do
      let(:service) { instance_double('NetworkPolicies::ResourcesService', execute: ServiceResponse.success(payload: [policy])) }
      let(:policy) do
        Gitlab::Kubernetes::NetworkPolicy.new(
          name: 'policy',
          namespace: 'another',
          selector: { matchLabels: { role: 'db' } },
          ingress: [{ from: [{ namespaceSelector: { matchLabels: { project: 'myproject' } } }] }]
        )
      end

      before do
        group.add_developer(user)
        allow(NetworkPolicies::ResourcesService).to receive(:new).with(environment_id: environment.id.to_s, project: project) { service }
      end

      it 'responds with policies' do
        subject

        expect(response).to have_gitlab_http_status(:success)
        expect(response.body).to eq([policy].to_json)
      end

      include_examples 'CRUD service errors'
    end

    context 'with unauthorized user' do
      it 'returns unauthorized' do
        subject

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end
  end

  describe 'POST #create' do
    subject { post :create, params: action_params.merge(manifest: manifest), format: :json }

    let(:service) { instance_double('NetworkPolicies::DeployResourceService', execute: ServiceResponse.success(payload: policy)) }
    let(:policy) do
      Gitlab::Kubernetes::NetworkPolicy.new(
        name: 'policy',
        namespace: 'another',
        selector: { matchLabels: { role: 'db' } },
        ingress: [{ from: [{ namespaceSelector: { matchLabels: { project: 'myproject' } } }] }]
      )
    end

    context 'with authorized user' do
      before do
        group.add_developer(user)
        allow(NetworkPolicies::DeployResourceService).to(
          receive(:new)
            .with(manifest: manifest, environment: environment)
            .and_return(service)
        )
      end

      it 'responds with success' do
        subject

        expect(response).to have_gitlab_http_status(:success)
        expect(response.body).to eq(policy.to_json)
      end

      include_examples 'CRUD service errors'
    end

    context 'with unauthorized user' do
      it 'returns unauthorized' do
        subject

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end
  end

  describe 'PUT #update' do
    subject { put :update, params: action_params.merge(id: 'example-policy', manifest: manifest, enabled: enabled), as: :json }

    let(:enabled) { nil }
    let(:service) { instance_double('NetworkPolicies::DeployResourceService', execute: ServiceResponse.success(payload: policy)) }
    let(:policy) do
      Gitlab::Kubernetes::NetworkPolicy.new(
        name: 'policy',
        namespace: 'another',
        selector: { matchLabels: { role: 'db' } },
        ingress: [{ from: [{ namespaceSelector: { matchLabels: { project: 'myproject' } } }] }]
      )
    end

    context 'with authorized user' do
      before do
        group.add_developer(user)
        allow(NetworkPolicies::DeployResourceService).to(
          receive(:new)
            .with(manifest: manifest, environment: environment, enabled: enabled, resource_name: 'example-policy')
            .and_return(service)
        )
      end

      it 'responds with success' do
        subject

        expect(response).to have_gitlab_http_status(:success)
        expect(response.body).to eq(policy.to_json)
      end

      include_examples 'CRUD service errors'
    end

    context 'with unauthorized user' do
      it 'returns unauthorized' do
        subject

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE #destroy' do
    subject { delete :destroy, params: action_params.merge(id: 'example-policy', manifest: manifest), format: :json }

    let(:service) { instance_double('NetworkPolicies::DeleteResourceService', execute: ServiceResponse.success) }

    context 'with authorized user' do
      before do
        group.add_developer(user)
        allow(NetworkPolicies::DeleteResourceService).to(
          receive(:new)
            .with(environment: environment, manifest: manifest, resource_name: 'example-policy')
            .and_return(service)
        )
      end

      it 'responds with success' do
        subject

        expect(response).to have_gitlab_http_status(:success)
      end

      include_examples 'CRUD service errors'
    end

    context 'with unauthorized user' do
      it 'returns unauthorized' do
        subject

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end
  end
end
