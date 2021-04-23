# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::ThreatMonitoringController do
  let_it_be(:project) { create(:project, :repository, :private) }
  let_it_be(:alert) { create(:alert_management_alert, :cilium, project: project) }
  let_it_be(:user) { create(:user) }

  describe 'GET show' do
    subject { get :show, params: { namespace_id: project.namespace, project_id: project } }

    context 'with authorized user' do
      before do
        project.add_developer(user)
        sign_in(user)
      end

      context 'when feature is available' do
        before do
          stub_licensed_features(threat_monitoring: true)
        end

        it 'renders the show template' do
          subject

          expect(response).to have_gitlab_http_status(:ok)
          expect(response).to render_template(:show)
        end
      end

      context 'when feature is not available' do
        before do
          stub_licensed_features(threat_monitoring: false)
        end

        it 'returns 404' do
          subject

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end

    context 'with unauthorized user' do
      before do
        sign_in(user)
      end

      context 'when feature is available' do
        before do
          stub_licensed_features(threat_monitoring: true)
        end

        it 'returns 404' do
          subject

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end

    context 'with anonymous user' do
      it 'returns 302' do
        subject

        expect(response).to have_gitlab_http_status(:found)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET new' do
    subject { get :new, params: { namespace_id: project.namespace, project_id: project } }

    context 'with authorized user' do
      before do
        project.add_developer(user)
        sign_in(user)
      end

      context 'when feature is available' do
        before do
          stub_licensed_features(threat_monitoring: true)
        end

        it 'renders the new template' do
          subject

          expect(response).to have_gitlab_http_status(:ok)
          expect(response).to render_template(:new)
        end
      end

      context 'when feature is not available' do
        before do
          stub_licensed_features(threat_monitoring: false)
        end

        it 'returns 404' do
          subject

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end

    context 'with unauthorized user' do
      before do
        sign_in(user)
      end

      context 'when feature is available' do
        before do
          stub_licensed_features(threat_monitoring: true)
        end

        it 'returns 404' do
          subject

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end

    context 'with anonymous user' do
      it 'returns 302' do
        subject

        expect(response).to have_gitlab_http_status(:found)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET edit' do
    subject do
      get :edit, params: { namespace_id: project.namespace, project_id: project, id: 'policy', environment_id: environment_id }
    end

    let_it_be(:environment) { create(:environment, :with_review_app, project: project) }

    let(:environment_id) { environment.id }

    context 'with authorized user' do
      before do
        project.add_developer(user)
        sign_in(user)
      end

      context 'when feature is available' do
        let(:service) { instance_double('NetworkPolicies::FindResourceService', execute: ServiceResponse.success(payload: policy)) }
        let(:policy) do
          Gitlab::Kubernetes::CiliumNetworkPolicy.new(
            name: 'policy',
            namespace: 'another',
            selector: { matchLabels: { role: 'db' } },
            ingress: [{ from: [{ namespaceSelector: { matchLabels: { project: 'myproject' } } }] }]
          )
        end

        before do
          stub_licensed_features(threat_monitoring: true)

          allow(NetworkPolicies::FindResourceService).to(
            receive(:new)
              .with(resource_name: 'policy', environment: environment, kind: Gitlab::Kubernetes::CiliumNetworkPolicy::KIND)
              .and_return(service)
          )
        end

        it 'renders the new template' do
          subject

          expect(response).to have_gitlab_http_status(:ok)
          expect(response).to render_template(:edit)
        end

        context 'when environment is missing' do
          let(:environment_id) { 'missing' }

          it 'returns 404' do
            subject

            expect(response).to have_gitlab_http_status(:not_found)
          end
        end

        context 'when service failed' do
          let(:service) { instance_double('NetworkPolicies::FindResourceService', execute: ServiceResponse.error(message: 'error')) }

          it 'returns 404' do
            subject

            expect(response).to have_gitlab_http_status(:not_found)
          end
        end
      end

      context 'when feature is not available' do
        before do
          stub_licensed_features(threat_monitoring: false)
        end

        it 'returns 404' do
          subject

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end

    context 'with unauthorized user' do
      before do
        sign_in(user)
      end

      context 'when feature is available' do
        before do
          stub_licensed_features(threat_monitoring: true)
        end

        it 'returns 404' do
          subject

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end

    context 'with anonymous user' do
      it 'returns 302' do
        subject

        expect(response).to have_gitlab_http_status(:found)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET threat monitoring alerts' do
    let(:alert_id) { alert.id }

    subject { get :alert_details, params: { namespace_id: project.namespace, project_id: project, id: alert_id } }

    context 'with authorized user' do
      before do
        project.add_developer(user)
        sign_in(user)
      end

      context 'with threat_monitoring feature and threat_monitoring_alerts feature flag' do
        using RSpec::Parameterized::TableSyntax

        where(:feature_flag, :feature, :http_status) do
          false | false | :not_found
          false | true  | :not_found
          true | false | :not_found
          true | true | :ok
        end

        with_them do
          before do
            stub_licensed_features(threat_monitoring: feature)
            stub_feature_flags(threat_monitoring_alerts: feature_flag)
          end
          specify do
            subject

            expect(response).to have_gitlab_http_status(http_status)
          end
        end
      end

      context 'when feature is available' do
        before do
          stub_licensed_features(threat_monitoring: true)
        end

        it 'renders the show template' do
          subject

          expect(response).to render_template(:alert_details)
        end

        context 'when id is invalid' do
          let(:alert_id) { nil }

          it 'raises an error' do
            expect { subject }.to raise_error(ActionController::UrlGenerationError)
          end
        end

        context 'when id is not found' do
          let(:alert_id) { non_existing_record_id }

          it 'renders not found' do
            subject

            expect(response).to have_gitlab_http_status(:not_found)
          end
        end
      end
    end

    context 'with unauthorized user' do
      before do
        sign_in(user)
      end

      context 'when feature is available' do
        before do
          stub_licensed_features(threat_monitoring: true)
        end

        it 'returns 404' do
          subject

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end

    context 'with anonymous user' do
      it 'returns 302' do
        subject

        expect(response).to have_gitlab_http_status(:found)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
