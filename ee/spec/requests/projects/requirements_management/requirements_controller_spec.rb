# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::RequirementsManagement::RequirementsController do
  include WorkhorseHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, :public) }
  let(:workhorse_token) { JWT.encode({ 'iss' => 'gitlab-workhorse' }, Gitlab::Workhorse.secret, 'HS256') }
  let(:workhorse_headers) { { 'GitLab-Workhorse' => '1.0', Gitlab::Workhorse::INTERNAL_API_REQUEST_HEADER => workhorse_token } }

  shared_examples 'response with 404 status' do
    it 'returns 404' do
      subject

      expect(response).to have_gitlab_http_status(:not_found)
    end
  end

  describe 'POST #import_csv' do
    let(:file) { fixture_file_upload('spec/fixtures/csv_comma.csv') }
    let(:params) { { namespace_id: project.namespace.id, path: 'test' } }

    subject { upload_file(file, workhorse_headers, params) }

    before do
      stub_feature_flags(import_requirements_csv: true)
    end

    context 'unauthorized' do
      context 'when user is not signed in' do
        it_behaves_like 'response with 404 status'
      end

      context 'with project member with a guest role' do
        before do
          login_as(user)
          project.add_guest(user)
        end

        it_behaves_like 'response with 404 status'
      end
    end

    context 'authorized' do
      before do
        login_as(user)
        project.add_reporter(user)
      end

      context 'when requirements feature is available and member is a reporter' do
        before do
          stub_licensed_features(requirements: true)
        end

        shared_examples 'response with 302 status' do
          it 'returns 302 status and redirects to the correct path' do
            subject

            expect(flash[:notice]).to eq(_("Your requirements are being imported. Once finished, you'll receive a confirmation email."))
            expect(response).to redirect_to(project_requirements_management_requirements_path(project))
            expect(response).to have_gitlab_http_status(:found)
          end
        end

        it_behaves_like 'response with 302 status'

        context 'when file extension is in upper case' do
          let(:file) { fixture_file_upload('spec/fixtures/csv_uppercase.CSV') }

          it_behaves_like 'response with 302 status'
        end

        it 'shows error when upload fails' do
          expect_next_instance_of(UploadService) do |upload_service|
            expect(upload_service).to receive(:execute).and_return(nil)
          end

          subject

          expect(flash[:alert]).to include(_('File upload error.'))
          expect(response).to redirect_to(project_requirements_management_requirements_path(project))
        end
      end

      context 'when requirements feature is not available' do
        before do
          stub_licensed_features(requirements: false)
        end

        it_behaves_like 'response with 404 status'
      end
    end

    context 'when requirements import FF is disabled' do
      before do
        stub_feature_flags(import_requirements_csv: false)
      end

      it_behaves_like 'response with 404 status'
    end

    def upload_file(file, headers = {}, params = {})
      workhorse_finalize(
        import_csv_project_requirements_management_requirements_path(project),
        method: :post,
        file_key: :file,
        params: params.merge(file: file),
        headers: headers,
        send_rewritten_field: true
      )
    end
  end

  describe 'POST #authorize' do
    subject do
      post authorize_project_requirements_management_requirements_path(project),
        headers: workhorse_headers
    end

    context 'with an authorized user' do
      before do
        project.add_reporter(user)
      end

      context 'when feature is available' do
        before do
          stub_licensed_features(requirements: true)
          stub_feature_flags(import_requirements_csv: true)
        end

        it_behaves_like 'handle uploads authorize request' do
          let(:uploader_class) { FileUploader }
        end
      end

      context 'when feature is disabled' do
        before do
          stub_licensed_features(requirements: true)
          stub_feature_flags(import_requirements_csv: true)
        end

        it_behaves_like 'response with 404 status'
      end
    end

    context 'with an authorized user' do
      it_behaves_like 'response with 404 status'
    end
  end
end
