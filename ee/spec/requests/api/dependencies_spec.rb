# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Dependencies do
  let_it_be(:project) { create(:project, :public) }
  let_it_be(:user) { create(:user) }

  describe "GET /projects/:id/dependencies" do
    subject(:request) { get api("/projects/#{project.id}/dependencies", user), params: params }

    let(:params) { {} }

    before do
      stub_licensed_features(dependency_scanning: true, security_dashboard: true)
    end

    it_behaves_like 'a gitlab tracking event', described_class.name, 'view_dependencies'

    context 'with an authorized user with proper permissions' do
      before do
        create(:ee_ci_pipeline, :with_dependency_list_report, project: project)
        project.add_developer(user)
        request
      end

      it 'returns all dependencies' do
        expect(response).to have_gitlab_http_status(:ok)
        expect(response).to match_response_schema('public_api/v4/dependencies', dir: 'ee')

        expect(json_response.length).to eq(21)
      end

      it 'returns vulnerabilities info' do
        vulnerability = json_response.select { |dep| dep['name'] == 'debug' }[0]['vulnerabilities'][0]

        expect(vulnerability['name']).to eq('Regular Expression Denial of Service in debug')
        expect(vulnerability['severity']).to eq('unknown')
      end

      context 'with nil package_manager' do
        let(:params) { { package_manager: nil } }

        it 'returns no dependencies' do
          expect(response).to have_gitlab_http_status(:ok)
          expect(response).to match_response_schema('public_api/v4/dependencies', dir: 'ee')

          expect(json_response).to eq([])
        end
      end

      context 'with filter options' do
        let(:params) { { package_manager: 'yarn' } }

        it 'returns yarn dependencies' do
          expect(json_response.length).to eq(19)
        end

        context 'with wrong key' do
          let(:params) { { package_manager: %w(nray yarn) } }

          it 'returns error message' do
            expect(json_response['error']).to eq('package_manager does not have a valid value')
          end
        end
      end
    end

    context 'without permissions to see vulnerabilities' do
      before do
        create(:ee_ci_pipeline, :with_dependency_list_report, project: project)
        request
      end

      it 'returns empty vulnerabilities' do
        expect(json_response.first['vulnerabilities']).to be_nil
      end
    end

    context 'with authorized user without read permissions' do
      let(:project) { create(:project, :private) }

      before do
        project.add_guest(user)
        request
      end

      it 'responds with 403 Forbidden' do
        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end

    context 'with no project access' do
      let(:project) { create(:project, :private) }

      before do
        request
      end

      it 'responds with 404 Not Found' do
        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end
end
