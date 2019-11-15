# frozen_string_literal: true
require 'spec_helper'

describe API::ConanPackages do
  let(:package) { create(:conan_package) }
  let_it_be(:personal_access_token) { create(:personal_access_token) }
  let_it_be(:user) { personal_access_token.user }
  let(:project) { package.project }

  let(:base_secret) { SecureRandom.base64(64) }
  let(:auth_token) { personal_access_token.token }

  let(:headers) do
    { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials('foo', auth_token) }
  end

  let(:jwt_secret) do
    OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest::SHA256.new,
      base_secret,
      Gitlab::ConanToken::HMAC_KEY
    )
  end

  before do
    project.add_developer(user)
    stub_licensed_features(packages: true)
    allow(Settings).to receive(:attr_encrypted_db_key_base).and_return(base_secret)
  end

  describe 'GET /api/v4/packages/conan/v1/ping' do
    context 'feature flag disabled' do
      before do
        stub_feature_flags(conan_package_registry: false)
      end

      it 'responds with 404 Not Found' do
        get api('/packages/conan/v1/ping')

        expect(response).to have_gitlab_http_status(404)
      end
    end

    context 'feature flag enabled' do
      it 'responds with 401 Unauthorized when no token provided' do
        get api('/packages/conan/v1/ping')

        expect(response).to have_gitlab_http_status(401)
      end

      it 'responds with 200 OK when valid token is provided' do
        jwt = build_jwt(personal_access_token)
        get api('/packages/conan/v1/ping'), headers: build_auth_headers(jwt.encoded)

        expect(response).to have_gitlab_http_status(200)
        expect(response.headers['X-Conan-Server-Capabilities']).to eq("")
      end

      it 'responds with 401 Unauthorized when invalid access token ID is provided' do
        jwt = build_jwt(double(id: 12345), user_id: personal_access_token.user_id)
        get api('/packages/conan/v1/ping'), headers: build_auth_headers(jwt.encoded)

        expect(response).to have_gitlab_http_status(401)
      end

      it 'responds with 401 Unauthorized when invalid user is provided' do
        jwt = build_jwt(personal_access_token, user_id: 12345)
        get api('/packages/conan/v1/ping'), headers: build_auth_headers(jwt.encoded)

        expect(response).to have_gitlab_http_status(401)
      end

      it 'responds with 401 Unauthorized when the provided JWT is signed with different secret' do
        jwt = build_jwt(personal_access_token, secret: SecureRandom.base64(32))
        get api('/packages/conan/v1/ping'), headers: build_auth_headers(jwt.encoded)

        expect(response).to have_gitlab_http_status(401)
      end

      it 'responds with 401 Unauthorized when invalid JWT is provided' do
        get api('/packages/conan/v1/ping'), headers: build_auth_headers('invalid-jwt')

        expect(response).to have_gitlab_http_status(401)
      end

      context 'packages feature disabled' do
        it 'responds with 404 Not Found' do
          stub_packages_setting(enabled: false)
          get api('/packages/conan/v1/ping')

          expect(response).to have_gitlab_http_status(404)
        end
      end
    end
  end

  describe 'GET /api/v4/packages/conan/v1/conans/search' do
    before do
      project.update!(visibility_level: Gitlab::VisibilityLevel::PUBLIC)

      get api('/packages/conan/v1/conans/search'), headers: headers, params: params
    end

    subject { json_response['results'] }

    context 'returns packages with a matching name' do
      let(:params) { { q: package.conan_recipe } }

      it { is_expected.to contain_exactly(package.conan_recipe) }
    end

    context 'returns packages using a * wildcard' do
      let(:params) { { q: "#{package.name[0, 3]}*" } }

      it { is_expected.to contain_exactly(package.conan_recipe) }
    end

    context 'does not return non-matching packages' do
      let(:params) { { q: "foo" } }

      it { is_expected.to be_blank }
    end
  end

  describe 'GET /api/v4/packages/conan/v1/users/authenticate' do
    subject { get api('/packages/conan/v1/users/authenticate'), headers: headers }

    context 'when using invalid token' do
      let(:auth_token) { 'invalid_token' }

      it 'responds with 401' do
        subject

        expect(response).to have_gitlab_http_status(401)
      end
    end

    context 'when valid JWT access token is provided' do
      it 'responds with 200' do
        subject

        expect(response).to have_gitlab_http_status(200)
      end

      it 'token has valid validity time' do
        Timecop.freeze do
          subject

          payload = JSONWebToken::HMACToken.decode(
            response.body, jwt_secret).first
          expect(payload['pat']).to eq(personal_access_token.id)
          expect(payload['u']).to eq(personal_access_token.user_id)

          duration = payload['exp'] - payload['iat']
          expect(duration).to eq(1.hour)
        end
      end
    end
  end

  describe 'GET /api/v4/packages/conan/v1/users/check_credentials' do
    it 'responds with a 200 OK' do
      get api('/packages/conan/v1/users/check_credentials'), headers: headers

      expect(response).to have_gitlab_http_status(200)
    end

    it 'responds with a 401 Unauthorized when an invalid token is used' do
      get api('/packages/conan/v1/users/check_credentials'), headers: build_auth_headers('invalid-token')

      expect(response).to have_gitlab_http_status(401)
    end
  end

  shared_examples 'rejects invalid recipe' do
    context 'with invalid recipe path' do
      let(:recipe_path) { '../../foo++../..' }

      it 'returns 400' do
        subject

        expect(response).to have_gitlab_http_status(400)
      end
    end
  end

  shared_examples 'rejects recipe for invalid project' do
    context 'with invalid recipe path' do
      let(:recipe_path) { 'aa/bb/not-existing-project/ccc' }

      it 'returns forbidden' do
        subject

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end
  end

  shared_examples 'rejects recipe for not found package' do
    context 'with invalid recipe path' do
      let(:recipe_path) do
        'aa/bb/%{project}/ccc' % { project: ::Packages::ConanMetadatum.package_username_from(full_path: project.full_path) }
      end

      it 'returns not found' do
        subject

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end

  shared_examples 'empty recipe for not found package' do
    context 'with invalid recipe url' do
      let(:recipe_path) do
        'aa/bb/%{project}/ccc' % { project: ::Packages::ConanMetadatum.package_username_from(full_path: project.full_path) }
      end

      it 'returns not found' do
        allow(ConanPackagePresenter).to receive(:new)
          .with(
            'aa/bb@%{project}/ccc' % { project: ::Packages::ConanMetadatum.package_username_from(full_path: project.full_path) },
            user,
            project
          ).and_return(presenter)
        allow(presenter).to receive(:recipe_snapshot) { {} }
        allow(presenter).to receive(:package_snapshot) { {} }

        subject

        expect(response).to have_gitlab_http_status(:ok)
        expect(response.body).to eq("{}")
      end
    end
  end

  shared_examples 'recipe download_urls' do
    let(:recipe_path) { package.conan_recipe_path }

    it 'returns the download_urls for the recipe files' do
      expected_response = {
        'conanfile.py'      => "#{Settings.gitlab.base_url}/api/v4/packages/conan/v1/files/#{package.conan_recipe_path}/0/export/conanfile.py",
        'conanmanifest.txt' => "#{Settings.gitlab.base_url}/api/v4/packages/conan/v1/files/#{package.conan_recipe_path}/0/export/conanmanifest.txt"
      }

      allow(presenter).to receive(:recipe_urls) { expected_response }

      subject

      expect(json_response).to eq(expected_response)
    end
  end

  shared_examples 'package download_urls' do
    let(:recipe_path) { package.conan_recipe_path }

    it 'returns the download_urls for the package files' do
      expected_response = {
        'conaninfo.txt'     => "#{Settings.gitlab.base_url}/api/v4/packages/conan/v1/files/#{package.conan_recipe_path}/0/package/123456789/0/conaninfo.txt",
        'conanmanifest.txt' => "#{Settings.gitlab.base_url}/api/v4/packages/conan/v1/files/#{package.conan_recipe_path}/0/package/123456789/0/conanmanifest.txt",
        'conan_package.tgz' => "#{Settings.gitlab.base_url}/api/v4/packages/conan/v1/files/#{package.conan_recipe_path}/0/package/123456789/0/conan_package.tgz"
      }

      allow(presenter).to receive(:package_urls) { expected_response }

      subject

      expect(json_response).to eq(expected_response)
    end
  end

  context 'recipe endpoints' do
    let(:jwt) { build_jwt(personal_access_token) }
    let(:headers) { build_auth_headers(jwt.encoded) }
    let(:conan_package_reference) { '123456789' }
    let(:presenter) { double('ConanPackagePresenter') }

    before do
      allow(ConanPackagePresenter).to receive(:new)
        .with(package.conan_recipe, user, package.project)
        .and_return(presenter)
    end

    describe 'GET /api/v4/packages/conan/v1/conans/:package_name/package_version/:package_username/:package_channel' do
      let(:recipe_path) { package.conan_recipe_path }

      subject { get api("/packages/conan/v1/conans/#{recipe_path}"), headers: headers }

      it_behaves_like 'rejects invalid recipe'
      it_behaves_like 'rejects recipe for invalid project'
      it_behaves_like 'empty recipe for not found package'

      context 'with existing package' do
        it 'returns a hash of files with their md5 hashes' do
          expected_response = {
            'conanfile.py'      => 'md5hash1',
            'conanmanifest.txt' => 'md5hash2'
          }

          allow(presenter).to receive(:recipe_snapshot) { expected_response }

          subject

          expect(json_response).to eq(expected_response)
        end
      end
    end

    describe 'GET /api/v4/packages/conan/v1/conans/:package_name/package_version/:package_username/:package_channel/packages/:conan_package_reference' do
      let(:recipe_path) { package.conan_recipe_path }

      subject { get api("/packages/conan/v1/conans/#{recipe_path}/packages/#{conan_package_reference}"), headers: headers }

      it_behaves_like 'rejects invalid recipe'
      it_behaves_like 'rejects recipe for invalid project'
      it_behaves_like 'empty recipe for not found package'

      context 'with existing package' do
        it 'returns a hash of md5 values for the files' do
          expected_response = {
            'conaninfo.txt'     => "md5hash1",
            'conanmanifest.txt' => "md5hash2",
            'conan_package.tgz' => "md5hash3"
          }

          allow(presenter).to receive(:package_snapshot) { expected_response }

          subject

          expect(json_response).to eq(expected_response)
        end
      end
    end

    describe 'GET /api/v4/packages/conan/v1/conans/:package_name/package_version/:package_username/:package_channel/digest' do
      subject { get api("/packages/conan/v1/conans/#{recipe_path}/digest"), headers: headers }

      it_behaves_like 'rejects invalid recipe'
      it_behaves_like 'rejects recipe for invalid project'
      it_behaves_like 'recipe download_urls'
    end

    describe 'GET /api/v4/packages/conan/v1/conans/:package_name/package_version/:package_username/:package_channel/packages/:conan_package_reference/download_urls' do
      subject { get api("/packages/conan/v1/conans/#{recipe_path}/packages/#{conan_package_reference}/download_urls"), headers: headers }

      it_behaves_like 'rejects invalid recipe'
      it_behaves_like 'rejects recipe for invalid project'
      it_behaves_like 'package download_urls'
    end

    describe 'GET /api/v4/packages/conan/v1/conans/:package_name/package_version/:package_username/:package_channel/download_urls' do
      subject { get api("/packages/conan/v1/conans/#{recipe_path}/download_urls"), headers: headers }

      it_behaves_like 'rejects invalid recipe'
      it_behaves_like 'rejects recipe for invalid project'
      it_behaves_like 'recipe download_urls'
    end

    describe 'GET /api/v4/packages/conan/v1/conans/:package_name/package_version/:package_username/:package_channel/packages/:conan_package_reference/digest' do
      subject { get api("/packages/conan/v1/conans/#{recipe_path}/packages/#{conan_package_reference}/digest"), headers: headers }

      it_behaves_like 'rejects invalid recipe'
      it_behaves_like 'rejects recipe for invalid project'
      it_behaves_like 'package download_urls'
    end

    describe 'POST /api/v4/packages/conan/v1/conans/:package_name/package_version/:package_username/:package_channel/upload_urls' do
      let(:recipe_path) { package.conan_recipe_path }

      let(:params) do
        { "conanfile.py": 24,
          "conanmanifext.txt": 123 }
      end

      subject { post api("/packages/conan/v1/conans/#{recipe_path}/upload_urls"), params: params, headers: headers }

      it_behaves_like 'rejects invalid recipe'

      it 'returns a set of upload urls for the files requested' do
        subject

        expected_response = {
          'conanfile.py':      "#{Settings.gitlab.base_url}/api/v4/packages/conan/v1/files/#{package.conan_recipe_path}/0/export/conanfile.py",
          'conanmanifest.txt': "#{Settings.gitlab.base_url}/api/v4/packages/conan/v1/files/#{package.conan_recipe_path}/0/export/conanmanifest.txt"
        }

        expect(response.body).to eq(expected_response.to_json)
      end
    end

    describe 'POST /api/v4/packages/conan/v1/conans/:package_name/package_version/:package_username/:package_channel/packages/:conan_package_reference/upload_urls' do
      let(:recipe_path) { package.conan_recipe_path }

      let(:params) do
        { "conaninfo.txt": 24,
          "conanmanifext.txt": 123,
          "conan_package.tgz": 523 }
      end

      subject { post api("/packages/conan/v1/conans/#{recipe_path}/packages/123456789/upload_urls"), params: params, headers: headers }

      it_behaves_like 'rejects invalid recipe'

      it 'returns a set of upload urls for the files requested' do
        expected_response = {
          'conaninfo.txt':     "#{Settings.gitlab.base_url}/api/v4/packages/conan/v1/files/#{package.conan_recipe_path}/0/package/123456789/0/conaninfo.txt",
          'conanmanifest.txt': "#{Settings.gitlab.base_url}/api/v4/packages/conan/v1/files/#{package.conan_recipe_path}/0/package/123456789/0/conanmanifest.txt",
          'conan_package.tgz': "#{Settings.gitlab.base_url}/api/v4/packages/conan/v1/files/#{package.conan_recipe_path}/0/package/123456789/0/conan_package.tgz"
        }

        subject

        expect(response.body).to eq(expected_response.to_json)
      end
    end

    describe 'DELETE /api/v4/packages/conan/v1/conans/:package_name/package_version/:package_username/:package_channel' do
      let(:recipe_path) { package.conan_recipe_path }

      subject { delete api("/packages/conan/v1/conans/#{recipe_path}"), headers: headers}

      it_behaves_like 'rejects invalid recipe'

      it 'returns unauthorized for users without valid permission' do
        subject

        expect(response).to have_gitlab_http_status(403)
      end

      context 'with delete permissions' do
        before do
          project.add_maintainer(user)
        end

        it 'deletes a package' do
          expect { subject }.to change { Packages::Package.count }.from(2).to(1)
        end
      end
    end
  end

  context 'file endpoints' do
    let(:jwt) { build_jwt(personal_access_token) }
    let(:headers) { build_auth_headers(jwt.encoded) }
    let(:recipe_path) { package.conan_recipe_path }

    shared_examples 'denies download with no token' do
      context 'with no private token' do
        let(:headers) { {} }

        it 'returns 400' do
          subject

          expect(response).to have_gitlab_http_status(401)
        end
      end
    end

    shared_examples 'a public project with packages' do
      it 'returns the file' do
        subject

        expect(response).to have_gitlab_http_status(200)
        expect(response.content_type.to_s).to eq('application/octet-stream')
      end
    end

    shared_examples 'an internal project with packages' do
      before do
        project.team.truncate
        project.update!(visibility_level: Gitlab::VisibilityLevel::INTERNAL)
      end

      it_behaves_like 'denies download with no token'

      it 'returns the file' do
        subject

        expect(response).to have_gitlab_http_status(200)
        expect(response.content_type.to_s).to eq('application/octet-stream')
      end
    end

    shared_examples 'a private project with packages' do
      before do
        project.update!(visibility_level: Gitlab::VisibilityLevel::PRIVATE)
      end

      it_behaves_like 'denies download with no token'

      it 'returns the file' do
        subject

        expect(response).to have_gitlab_http_status(200)
        expect(response.content_type.to_s).to eq('application/octet-stream')
      end

      it 'denies download when not enough permissions' do
        project.add_guest(user)

        subject

        expect(response).to have_gitlab_http_status(403)
      end
    end

    shared_examples 'a project is not found' do
      let(:recipe_path) { 'not/package/for/project' }

      it 'returns forbidden' do
        subject

        expect(response).to have_gitlab_http_status(403)
      end
    end

    describe 'GET /api/v4/packages/conan/v1/files/:package_name/package_version/:package_username/:package_channel/
:recipe_revision/export/:file_name' do
      let(:recipe_file) { package.package_files.find_by(file_name: 'conanfile.py') }
      let(:metadata) { recipe_file.conan_file_metadatum }

      subject do
        get api("/packages/conan/v1/files/#{recipe_path}/#{metadata.recipe_revision}/export/#{recipe_file.file_name}"),
            headers: headers
      end

      it_behaves_like 'a public project with packages'
      it_behaves_like 'an internal project with packages'
      it_behaves_like 'a private project with packages'
      it_behaves_like 'a project is not found'
    end

    describe 'GET /api/v4/packages/conan/v1/files/:package_name/package_version/:package_username/:package_channel/
:recipe_revision/package/:conan_package_reference/:package_revision/:file_name' do
      let(:package_file) { package.package_files.find_by(file_name: 'conaninfo.txt') }
      let(:metadata) { package_file.conan_file_metadatum }

      subject do
        get api("/packages/conan/v1/files/#{recipe_path}/#{metadata.recipe_revision}/package/#{metadata.conan_package_reference}/#{metadata.package_revision}/#{package_file.file_name}"),
            headers: headers
      end

      it_behaves_like 'a public project with packages'
      it_behaves_like 'an internal project with packages'
      it_behaves_like 'a private project with packages'
      it_behaves_like 'a project is not found'
    end
  end

  def build_jwt(personal_access_token, secret: jwt_secret, user_id: nil)
    JSONWebToken::HMACToken.new(secret).tap do |jwt|
      jwt['pat'] = personal_access_token.id
      jwt['u'] = user_id || personal_access_token.user_id
    end
  end

  def build_auth_headers(token)
    { 'HTTP_AUTHORIZATION' => "Bearer #{token}" }
  end
end
