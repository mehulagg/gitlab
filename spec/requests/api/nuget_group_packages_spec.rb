# frozen_string_literal: true
require 'spec_helper'

RSpec.describe API::NugetGroupPackages do
  include WorkhorseHelpers
  include PackagesManagerApiSpecHelpers
  include HttpBasicAuthHelpers

  let_it_be(:user) { create(:user) }
  let_it_be_with_reload(:group) { create(:group) }
  let_it_be_with_reload(:subgroup) { create(:group, parent: group) }
  let_it_be_with_reload(:project) { create(:project, namespace: subgroup) }
  let_it_be(:personal_access_token) { create(:personal_access_token, user: user) }
  let_it_be(:deploy_token) { create(:deploy_token, :group, read_package_registry: true, write_package_registry: true) }
  let_it_be(:group_deploy_token) { create(:group_deploy_token, deploy_token: deploy_token, group: group) }

  let(:target_type) { 'groups' }

  shared_examples 'handling all endpoints' do
    describe 'GET /api/v4/groups/:id/packages/nuget' do
      it_behaves_like 'handling nuget service requests' do
        let(:url) { "/groups/#{target.id}/packages/nuget/index.json" }
      end
    end

    describe 'GET /api/v4/groups/:id/packages/nuget/metadata/*package_name/index' do
      it_behaves_like 'handling nuget metadata requests with package name' do
        let(:url) { "/groups/#{target.id}/packages/nuget/metadata/#{package_name}/index.json" }
      end
    end

    describe 'GET /api/v4/groups/:id/packages/nuget/metadata/*package_name/*package_version' do
      it_behaves_like 'handling nuget metadata requests with package name and package version' do
        let(:url) { "/groups/#{target.id}/packages/nuget/metadata/#{package_name}/#{package.version}.json" }
      end
    end

    describe 'GET /api/v4/groups/:id/packages/nuget/download/*package_name/index' do
      it_behaves_like 'handling nuget download index requests' do
        let(:url) { "/groups/#{target.id}/packages/nuget/download/#{package_name}/index.json" }
      end
    end

    describe 'GET /api/v4/groups/:id/packages/nuget/download/*package_name/*package_version/*package_filename' do
      it_behaves_like 'handling nuget download file requests' do
        let(:url) { "/groups/#{target.id}/packages/nuget/download/#{package.name}/#{package.version}/#{package.name}.#{package.version}.nupkg" }
      end
    end

    describe 'GET /api/v4/groups/:id/packages/nuget/query' do
      it_behaves_like 'handling nuget search requests' do
        let(:url) { "/groups/#{target.id}/packages/nuget/query?#{query_parameters.to_query}" }
      end
    end
  end

  context 'with a subgroup' do
    # Bug: deploy tokens at parent group will not see the subgroup.
    # https://gitlab.com/gitlab-org/gitlab/-/issues/285495
    let_it_be(:group_deploy_token) { create(:group_deploy_token, deploy_token: deploy_token, group: subgroup) }

    let(:target) { subgroup }

    it_behaves_like 'handling all endpoints'

    def update_visibility_to(visibility)
      project.update!(visibility_level: visibility)
      subgroup.update!(visibility_level: visibility)
    end
  end

  context 'a group' do
    let(:target) { group }

    it_behaves_like 'handling all endpoints'

    def update_visibility_to(visibility)
      project.update!(visibility_level: visibility)
      subgroup.update!(visibility_level: visibility)
      group.update!(visibility_level: visibility)
    end
  end
end
