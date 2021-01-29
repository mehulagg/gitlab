# frozen_string_literal: true

RSpec.shared_examples 'handling get metadata requests' do |scope: :project|
  using RSpec::Parameterized::TableSyntax

  let_it_be(:package_dependency_link1) { create(:packages_dependency_link, package: package, dependency_type: :dependencies) }
  let_it_be(:package_dependency_link2) { create(:packages_dependency_link, package: package, dependency_type: :devDependencies) }
  let_it_be(:package_dependency_link3) { create(:packages_dependency_link, package: package, dependency_type: :bundleDependencies) }
  let_it_be(:package_dependency_link4) { create(:packages_dependency_link, package: package, dependency_type: :peerDependencies) }

  let(:headers) { {} }

  subject { get(url, headers: headers) }

  before do
    package.update!(name: package_name) unless package_name == 'non-existing-package'
  end

  shared_examples 'accept metadata request' do |status:|
    it 'accepts the metadata request' do
      subject

      expect(response).to have_gitlab_http_status(status)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('public_api/v4/packages/npm_package')
      expect(json_response['name']).to eq(package.name)
      expect(json_response['versions'][package.version]).to match_schema('public_api/v4/packages/npm_package_version')
      ::Packages::Npm::PackagePresenter::NPM_VALID_DEPENDENCY_TYPES.each do |dependency_type|
        expect(json_response.dig('versions', package.version, dependency_type.to_s)).to be_any
      end
      expect(json_response['dist-tags']).to match_schema('public_api/v4/packages/npm_package_tags')
    end
  end

  shared_examples 'reject metadata request' do |status:|
    it 'rejects the metadata request' do
      subject

      expect(response).to have_gitlab_http_status(status)
    end
  end

  shared_examples 'redirect metadata request' do |status:|
    it 'redirects metadata request' do
      subject

      expect(response).to have_gitlab_http_status(:found)
      expect(response.headers['Location']).to eq("https://registry.npmjs.org/#{package_name}")
    end
  end

  shared_examples 'handling different visibilities and user roles' do |accept_example: 'accept metadata request', accept_status: :ok, reject_example: 'reject metadata request', reject_status: nil|
    where(:visibility, :user_role, :example_name, :expected_status) do
      'PUBLIC'   | :anonymous | accept_example | accept_status
      'PUBLIC'   | :guest     | accept_example | accept_status
      'PUBLIC'   | :reporter  | accept_example | accept_status
      'PRIVATE'  | :anonymous | reject_example | (reject_status || :not_found)
      'PRIVATE'  | :guest     | reject_example | (reject_status || :forbidden)
      'PRIVATE'  | :reporter  | accept_example | accept_status
      'INTERNAL' | :anonymous | reject_example | (reject_status || :not_found)
      'INTERNAL' | :guest     | accept_example | accept_status
      'INTERNAL' | :reporter  | accept_example | accept_status
    end

    with_them do
      let(:anonymous) { user_role == :anonymous }

      subject { get(url, headers: anonymous ? {} : headers) }

      before do
        project.send("add_#{user_role}", user) unless anonymous
        project.update!(visibility: Gitlab::VisibilityLevel.const_get(visibility, false))
      end

      it_behaves_like params[:example_name], status: params[:expected_status]
    end
  end

  shared_examples 'handling different package names' do
    context 'handling a scoped package following the naming convention' do
      let(:package_name) { "@#{group.path}/scoped-package" }

      context 'with request forward enabled' do
        include_context 'npm request forward enabled'

        it_behaves_like 'handling different visibilities and user roles'
      end

      context 'with request forward disabled' do
        include_context 'npm request forward disabled'

        it_behaves_like 'handling different visibilities and user roles'
      end
    end

    context 'handling a scoped package not following the naming convention' do
      let(:package_name) { '@any_scope/scope-package' }

      context 'with request forward enabled' do
        include_context 'npm request forward enabled'

        params = {}
        params = { accept_example: 'redirect metadata request', accept_status: :redirected, reject_example: 'redirect metadata request', reject_status: :redirected } if scope == :instance

        it_behaves_like 'handling different visibilities and user roles', **params
      end

      context 'with request forward disabled' do
        include_context 'npm request forward disabled'

        params = {}
        params = { accept_example: 'reject metadata request', accept_status: :not_found, reject_status: :not_found } if scope == :instance

        it_behaves_like 'handling different visibilities and user roles', **params
      end
    end

    context 'handling an unscoped package' do
      let(:package_name) { 'unscoped-package' }

      context 'with request forward enabled' do
        include_context 'npm request forward enabled'

        params = {}
        params = { accept_example: 'redirect metadata request', accept_status: :redirected, reject_example: 'redirect metadata request', reject_status: :redirected } if scope == :instance

        it_behaves_like 'handling different visibilities and user roles', **params
      end

      context 'with request forward disabled' do
        include_context 'npm request forward disabled'

        params = {}
        params = { accept_example: 'reject metadata request', accept_status: :not_found, reject_status: :not_found } if scope == :instance

        it_behaves_like 'handling different visibilities and user roles', **params
      end
    end

    context 'handling a package name with a dot in the project path' do
      let(:package_name) { "@#{group.path}/scoped-package" }

      before do
        project.update!(path: 'foo.bar')
      end

      context 'with request forward enabled' do
        include_context 'npm request forward enabled'

        it_behaves_like 'handling different visibilities and user roles'
      end

      context 'with request forward disabled' do
        include_context 'npm request forward disabled'

        it_behaves_like 'handling different visibilities and user roles'
      end
    end

    context 'handling a non existing package' do
      let(:package_name) { 'non-existing-package' }

      context 'with request forward enabled' do
        include_context 'npm request forward enabled'

        it_behaves_like 'handling different visibilities and user roles', accept_example: 'redirect metadata request', accept_status: :redirected, reject_example: 'redirect metadata request', reject_status: :redirected
      end

      context 'with request forward disabled' do
        include_context 'npm request forward disabled'

        reject_status = :not_found if scope == :instance
        it_behaves_like 'handling different visibilities and user roles', accept_example: 'reject metadata request', accept_status: :not_found, reject_status: reject_status
      end
    end
  end

  shared_examples 'handling different package names for a given user role' do
    context 'handling a scoped package following the naming convention' do
      let(:package_name) { "@#{group.path}/scoped-package" }

      it_behaves_like 'handling request forward and accepting the request'
    end

    context 'handling a scoped package not following the naming convention' do
      let(:package_name) { '@any_scope/scope-package' }

      it_behaves_like 'handling request forward and accepting the request except for the instance scope'
    end

    context 'handling an unscoped package' do
      let(:package_name) { 'unscoped-package' }

      it_behaves_like 'handling request forward and accepting the request except for the instance scope'
    end

    context 'handling a package name with a dot in the project path' do
      let(:package_name) { "@#{group.path}/scoped-package" }

      before do
        project.update!(path: 'foo.bar')
      end

      it_behaves_like 'handling request forward and accepting the request'
    end

    context 'handling a non existing package' do
      let(:package_name) { 'non-existing-package' }

      context 'with request forward enabled' do
        include_context 'npm request forward enabled'

        it_behaves_like 'redirect metadata request', status: :redirect
      end

      context 'with request forward disabled' do
        include_context 'npm request forward disabled'

        it_behaves_like 'reject metadata request', status: :not_found
      end
    end
  end

  shared_examples 'handling request forward and accepting the request' do
    context 'with request forward enabled' do
      include_context 'npm request forward enabled'

      it_behaves_like 'accept metadata request', status: :ok
    end

    context 'with request forward disabled' do
      include_context 'npm request forward disabled'

      it_behaves_like 'accept metadata request', status: :ok
    end
  end

  shared_examples 'handling request forward and accepting the request except for the instance scope' do
    context 'with request forward enabled' do
      include_context 'npm request forward enabled'

      if scope == :project
        it_behaves_like 'accept metadata request', status: :ok
      else
        it_behaves_like 'redirect metadata request', status: :redirect
      end
    end

    context 'with request forward disabled' do
      include_context 'npm request forward disabled'

      if scope == :project
        it_behaves_like 'accept metadata request', status: :ok
      else
        it_behaves_like 'reject metadata request', status: :not_found
      end
    end
  end

  context 'with oauth token' do
    let(:headers) { build_token_auth_header(token.token) }

    it_behaves_like 'handling different package names'
  end

  context 'with personal access token' do
    let(:headers) { build_token_auth_header(personal_access_token.token) }

    it_behaves_like 'handling different package names'
  end

  context 'with job token' do
    let(:headers) { build_token_auth_header(job.token) }

    before do
      project.add_developer(user)
    end

    it_behaves_like 'handling different package names for a given user role'

    context 'without running job' do
      let(:package_name) { "@#{group.path}/scoped-package" }

      before do
        job.update!(status: :success)
      end

      context 'with request forward enabled' do
        include_context 'npm request forward enabled'

        it_behaves_like 'reject metadata request', status: :unauthorized
      end

      context 'with request forward disabled' do
        include_context 'npm request forward disabled'

        it_behaves_like 'reject metadata request', status: :unauthorized
      end
    end
  end

  context 'with deploy token' do
    let(:headers) { build_token_auth_header(deploy_token.token) }

    it_behaves_like 'handling different package names for a given user role'
  end
end

RSpec.shared_examples 'handling get dist tags requests' do
  let_it_be(:package_tag1) { create(:packages_tag, package: package) }
  let_it_be(:package_tag2) { create(:packages_tag, package: package) }

  let(:params) { {} }

  subject { get(url, params: params) }

  context 'with public project' do
    context 'with authenticated user' do
      let(:params) { { private_token: personal_access_token.token } }

      it_behaves_like 'returns package tags', :maintainer
      it_behaves_like 'returns package tags', :developer
      it_behaves_like 'returns package tags', :reporter
      it_behaves_like 'returns package tags', :guest
    end

    context 'with unauthenticated user' do
      it_behaves_like 'returns package tags', :no_type
    end
  end

  context 'with private project' do
    before do
      project.update!(visibility_level: Gitlab::VisibilityLevel::PRIVATE)
    end

    context 'with authenticated user' do
      let(:params) { { private_token: personal_access_token.token } }

      it_behaves_like 'returns package tags', :maintainer
      it_behaves_like 'returns package tags', :developer
      it_behaves_like 'returns package tags', :reporter
      it_behaves_like 'rejects package tags access', :guest, :forbidden
    end

    context 'with unauthenticated user' do
      it_behaves_like 'rejects package tags access', :no_type, :not_found
    end
  end
end

RSpec.shared_examples 'handling create dist tag requests' do
  let_it_be(:tag_name) { 'test' }

  let(:params) { {} }
  let(:env) { {} }
  let(:version) { package.version }

  subject { put(url, env: env, params: params) }

  context 'with public project' do
    context 'with authenticated user' do
      let(:params) { { private_token: personal_access_token.token } }
      let(:env) { { 'api.request.body': version } }

      it_behaves_like 'create package tag', :maintainer
      it_behaves_like 'create package tag', :developer
      it_behaves_like 'rejects package tags access', :reporter, :forbidden
      it_behaves_like 'rejects package tags access', :guest, :forbidden
    end

    context 'with unauthenticated user' do
      it_behaves_like 'rejects package tags access', :no_type, :unauthorized
    end
  end
end

RSpec.shared_examples 'handling delete dist tag requests' do
  let_it_be(:package_tag) { create(:packages_tag, package: package) }

  let(:params) { {} }
  let(:tag_name) { package_tag.name }

  subject { delete(url, params: params) }

  context 'with public project' do
    context 'with authenticated user' do
      let(:params) { { private_token: personal_access_token.token } }

      it_behaves_like 'delete package tag', :maintainer
      it_behaves_like 'rejects package tags access', :developer, :forbidden
      it_behaves_like 'rejects package tags access', :reporter, :forbidden
      it_behaves_like 'rejects package tags access', :guest, :forbidden
    end

    context 'with unauthenticated user' do
      it_behaves_like 'rejects package tags access', :no_type, :unauthorized
    end
  end

  context 'with private project' do
    before do
      project.update!(visibility_level: Gitlab::VisibilityLevel::PRIVATE)
    end

    context 'with authenticated user' do
      let(:params) { { private_token: personal_access_token.token } }

      it_behaves_like 'delete package tag', :maintainer
      it_behaves_like 'rejects package tags access', :developer, :forbidden
      it_behaves_like 'rejects package tags access', :reporter, :forbidden
      it_behaves_like 'rejects package tags access', :guest, :forbidden
    end

    context 'with unauthenticated user' do
      it_behaves_like 'rejects package tags access', :no_type, :unauthorized
    end
  end
end
