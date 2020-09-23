# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Git HTTP requests' do
  include GitHttpHelpers
  include WorkhorseHelpers

  shared_examples_for 'pulls are allowed' do
    specify do
      download(path, env) do |response|
        expect(response).to have_gitlab_http_status(:ok)
        expect(response.media_type).to eq(Gitlab::Workhorse::INTERNAL_API_CONTENT_TYPE)
      end
    end
  end

  shared_examples_for 'pushes are allowed' do
    specify do
      upload(path, env) do |response|
        expect(response).to have_gitlab_http_status(:ok)
        expect(response.media_type).to eq(Gitlab::Workhorse::INTERNAL_API_CONTENT_TYPE)
      end
    end
  end

  describe "User with no identities" do
    let(:user) { create(:user) }
    let(:project) { create(:project, :repository, :private) }
    let(:path) { "#{project.full_path}.git" }

    context "when Kerberos token is provided" do
      let(:env) { { spnego_request_token: 'opaque_request_token' } }

      before do
        allow_any_instance_of(Repositories::GitHttpController).to receive(:allow_kerberos_spnego_auth?).and_return(true)
      end

      context "when authentication fails because of invalid Kerberos token" do
        before do
          allow_any_instance_of(Repositories::GitHttpController).to receive(:spnego_credentials!).and_return(nil)
        end

        it "responds with status 401 Unauthorized" do
          download(path, env) do |response|
            expect(response).to have_gitlab_http_status(:unauthorized)
          end
        end
      end

      context "when authentication fails because of unknown Kerberos identity" do
        before do
          allow_any_instance_of(Repositories::GitHttpController).to receive(:spnego_credentials!).and_return("mylogin@FOO.COM")
        end

        it "responds with status 401 Unauthorized" do
          download(path, env) do |response|
            expect(response).to have_gitlab_http_status(:unauthorized)
          end
        end
      end

      context "when authentication succeeds" do
        before do
          allow_any_instance_of(Repositories::GitHttpController).to receive(:spnego_credentials!).and_return("mylogin@FOO.COM")
          user.identities.create!(provider: "kerberos", extern_uid: "mylogin@FOO.COM")
        end

        context "when the user has access to the project" do
          before do
            project.add_maintainer(user)
          end

          context "when the user is blocked" do
            before do
              user.block
              project.add_maintainer(user)
            end

            it "responds with status 403 Forbidden" do
              download(path, env) do |response|
                expect(response).to have_gitlab_http_status(:forbidden)
              end
            end
          end

          context "when the user isn't blocked", :redis do
            it "responds with status 200 OK" do
              download(path, env) do |response|
                expect(response).to have_gitlab_http_status(:ok)
              end
            end

            it 'updates the user last activity' do
              expect(user.last_activity_on).to be_nil

              download(path, env) do |_response|
                expect(user.reload.last_activity_on).to eql(Date.today)
              end
            end
          end

          it "complies with RFC4559" do
            allow_any_instance_of(Repositories::GitHttpController).to receive(:spnego_response_token).and_return("opaque_response_token")
            download(path, env) do |response|
              expect(response.headers['WWW-Authenticate'].split("\n")).to include("Negotiate #{::Base64.strict_encode64('opaque_response_token')}")
            end
          end
        end

        context "when the user doesn't have access to the project" do
          it "responds with status 404 Not Found" do
            download(path, env) do |response|
              expect(response).to have_gitlab_http_status(:not_found)
            end
          end

          it "complies with RFC4559" do
            allow_any_instance_of(Repositories::GitHttpController).to receive(:spnego_response_token).and_return("opaque_response_token")
            download(path, env) do |response|
              expect(response.headers['WWW-Authenticate'].split("\n")).to include("Negotiate #{::Base64.strict_encode64('opaque_response_token')}")
            end
          end
        end
      end
    end

    context 'when license is not provided' do
      let(:env) { { user: user.username, password: user.password } }

      before do
        allow(License).to receive(:current).and_return(nil)

        project.add_maintainer(user)
      end

      it_behaves_like 'pulls are allowed'
      it_behaves_like 'pushes are allowed'
    end
  end

  describe 'when SSO is enforced' do
    let(:user) { create(:user) }
    let(:group) { create(:group) }
    let(:project) { create(:project, :repository, :private, group: group) }
    let(:env) { { user: user.username, password: user.password } }
    let(:path) { "#{project.full_path}.git" }

    before do
      project.add_developer(user)
      create(:saml_provider, group: group, enforced_sso: true)
    end

    it_behaves_like 'pulls are allowed'
  end
end
