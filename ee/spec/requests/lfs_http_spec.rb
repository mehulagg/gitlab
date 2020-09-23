# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Git LFS API and storage' do
  include WorkhorseHelpers

  let(:user) { create(:user) }
  let!(:lfs_object) { create(:lfs_object, :with_file) }

  let(:headers) do
    {
      'Authorization' => authorization,
      'X-Sendfile-Type' => sendfile
    }.compact
  end

  let(:authorization) { }
  let(:sendfile) { }

  let(:sample_oid) { lfs_object.oid }
  let(:sample_size) { lfs_object.size }

  describe 'when handling lfs batch request' do
    let(:update_lfs_permissions) { }
    let(:update_user_permissions) { }

    before do
      enable_lfs
      update_lfs_permissions
      update_user_permissions
      post_lfs_json "#{project.http_url_to_repo}/info/lfs/objects/batch", body, headers
    end

    describe 'upload' do
      let(:project) { create(:project, :public) }
      let(:body) do
        {
          'operation' => 'upload',
          'objects' => [
            { 'oid' => sample_oid,
              'size' => sample_size }
          ]
        }
      end

      shared_examples 'pushes new LFS objects' do
        let(:sample_size) { 150.megabytes }
        let(:sample_oid) { '91eff75a492a3ed0dfcb544d7f31326bc4014c8551849c192fd1e48d4dd2c897' }

        context 'and project is above the limit' do
          let(:update_lfs_permissions) do
            allow_next_instance_of(Gitlab::RepositorySizeChecker) do |checker|
              allow(checker).to receive_messages(
                enabled?: true,
                current_size: 110.megabytes,
                limit: 100.megabytes
              )
            end
          end

          it 'responds with status 406' do
            expect(response).to have_gitlab_http_status(:not_acceptable)
            expect(json_response['message']).to eql('Your push has been rejected, because this repository has exceeded its size limit of 100 MB by 160 MB. Please contact your GitLab administrator for more information.')
          end
        end

        context 'and project will go over the limit' do
          let(:update_lfs_permissions) do
            allow_next_instance_of(Gitlab::RepositorySizeChecker) do |checker|
              allow(checker).to receive_messages(
                enabled?: true,
                current_size: 200.megabytes,
                limit: 300.megabytes
              )
            end
          end

          it 'responds with status 406' do
            expect(response).to have_gitlab_http_status(:not_acceptable)
            expect(json_response['documentation_url']).to include('/help')
            expect(json_response['message']).to eql('Your push has been rejected, because this repository has exceeded its size limit of 300 MB by 50 MB. Please contact your GitLab administrator for more information.')
          end
        end
      end

      describe 'when request is authenticated' do
        context 'when user has project push access' do
          let(:authorization) { authorize_user }
          let(:update_user_permissions) { project.add_developer(user) }

          context 'when pushing a lfs object that does not exist' do
            it_behaves_like 'pushes new LFS objects'
          end
        end

        context 'when deploy key has project push access' do
          let(:key) { create(:deploy_key) }
          let(:authorization) { authorize_deploy_key }

          let(:update_user_permissions) do
            project.deploy_keys_projects.create(deploy_key: key, can_push: true)
          end

          it_behaves_like 'pushes new LFS objects'
        end
      end
    end
  end

  describe 'when pushing a lfs object' do
    before do
      enable_lfs
    end

    describe 'to one project' do
      let(:project) { create(:project) }

      context 'when user is authenticated' do
        let(:authorization) { authorize_user }

        context 'when user has push access to the project' do
          before do
            project.add_developer(user)
          end

          context 'and project has limit enabled but will stay under the limit' do
            before do
              allow_next_instance_of(Gitlab::RepositorySizeChecker) do |checker|
                allow(checker).to receive_messages(limit: 200, enabled?: true)
              end

              put_finalize
            end

            it 'responds with status 200' do
              expect(response).to have_gitlab_http_status(:ok)
            end
          end
        end
      end
    end

    def put_finalize(lfs_tmp = lfs_tmp_file, with_tempfile: false, verified: true, args: {})
      upload_path = LfsObjectUploader.workhorse_local_upload_path
      file_path = upload_path + '/' + lfs_tmp if lfs_tmp

      if with_tempfile
        FileUtils.mkdir_p(upload_path)
        FileUtils.touch(file_path)
      end

      extra_args = {
        'file.path' => file_path,
        'file.name' => File.basename(file_path)
      }

      put_finalize_with_args(args.merge(extra_args).compact, verified: verified)
    end

    def put_finalize_with_args(args, verified:)
      finalize_headers = headers
      finalize_headers.merge!(workhorse_internal_api_request_header) if verified

      put "#{project.http_url_to_repo}/gitlab-lfs/objects/#{sample_oid}/#{sample_size}", params: args, headers: finalize_headers
    end

    def lfs_tmp_file
      "#{sample_oid}012345678"
    end
  end

  def enable_lfs
    allow(Gitlab.config.lfs).to receive(:enabled).and_return(true)
  end

  def authorize_user
    ActionController::HttpAuthentication::Basic.encode_credentials(user.username, user.password)
  end

  def authorize_deploy_key
    ActionController::HttpAuthentication::Basic.encode_credentials("lfs+deploy-key-#{key.id}", Gitlab::LfsToken.new(key).token)
  end

  def post_lfs_json(url, body = nil, headers = nil)
    params = body.try(:to_json)
    headers = (headers || {}).merge('Content-Type' => LfsRequest::CONTENT_TYPE)

    post(url, params: params, headers: headers)
  end
end
