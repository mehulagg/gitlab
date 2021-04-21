# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['DastSiteProfile'] do
  include GraphqlHelpers

  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user, developer_projects: [project]) }
  let_it_be(:object, reload: true) { create(:dast_site_profile, project: project) }
  let_it_be(:fields) { %i[id profileName targetUrl targetType editPath excludedUrls requestHeaders validationStatus userPermissions normalizedTargetUrl auth referencedInSecurityPolicies] }

  before do
    stub_licensed_features(security_on_demand_scans: true)
  end

  specify { expect(described_class.graphql_name).to eq('DastSiteProfile') }
  specify { expect(described_class).to require_graphql_authorizations(:read_on_demand_scans) }
  specify { expect(described_class).to expose_permissions_using(Types::PermissionTypes::DastSiteProfile) }

  it { expect(described_class).to have_graphql_fields(fields) }
  it { expect(described_class).to have_graphql_field(:referenced_in_security_policies, calls_gitaly?: true, complexity: 10) }

  describe 'id field' do
    it 'is the global id' do
      expect(resolve_field(:id, object, current_user: user)).to eq(object.to_global_id)
    end
  end

  describe 'profileName field' do
    it 'is the name' do
      expect(resolve_field(:profile_name, object, current_user: user)).to eq(object.name)
    end
  end

  describe 'targetUrl field' do
    it 'is the url of the associated dast_site' do
      expect(resolve_field(:target_url, object, current_user: user)).to eq(object.dast_site.url)
    end
  end

  describe 'targetType field' do
    context 'when the feature flag is disabled' do
      it 'is nil' do
        stub_feature_flags(security_dast_site_profiles_api_option: false)

        expect(resolve_field(:target_type, object, current_user: user)).to be_nil
      end
    end

    context 'when the feature flag is enabled' do
      it 'is the target type' do
        expect(resolve_field(:target_type, object, current_user: user)).to eq('website')
      end
    end
  end

  describe 'editPath field' do
    it 'is the relative path to edit the dast_site_profile' do
      path = "/#{project.full_path}/-/security/configuration/dast_scans/dast_site_profiles/#{object.id}/edit"

      expect(resolve_field(:edit_path, object, current_user: user)).to eq(path)
    end
  end

  describe 'auth field' do
    context 'when the feature flag is disabled' do
      it 'is nil' do
        stub_feature_flags(security_dast_site_profiles_additional_fields: false)

        expect(resolve_field(:auth, object, current_user: user)).to be_nil
      end
    end

    context 'when the feature flag is enabled' do
      it 'is the dast_site_profile' do
        expect(resolve_field(:auth, object, current_user: user)).to eq(object)
      end
    end
  end

  describe 'excludedUrls field' do
    context 'when the feature flag is disabled' do
      it 'is nil' do
        stub_feature_flags(security_dast_site_profiles_additional_fields: false)

        expect(resolve_field(:excluded_urls, object, current_user: user)).to be_nil
      end
    end

    context 'when the feature flag is enabled' do
      it 'is the excluded urls' do
        expect(resolve_field(:excluded_urls, object, current_user: user)).to eq(object.excluded_urls)
      end
    end
  end

  describe 'requestHeaders field' do
    context 'when the feature flag is disabled' do
      it 'is nil' do
        stub_feature_flags(security_dast_site_profiles_additional_fields: false)

        expect(resolve_field(:request_headers, object, current_user: user)).to be_nil
      end
    end

    context 'when the feature flag is enabled' do
      context 'when there is no associated secret variable' do
        it 'is nil' do
          expect(resolve_field(:request_headers, object, current_user: user)).to be_nil
        end
      end

      context 'when there an associated secret variable' do
        it 'is redacted' do
          create(:dast_site_profile_secret_variable, dast_site_profile: object, key: Dast::SiteProfileSecretVariable::REQUEST_HEADERS)

          expect(resolve_field(:request_headers, object, current_user: user)).to eq('••••••••')
        end
      end
    end
  end

  describe 'validation_status field' do
    it 'is the validation status' do
      expect(resolve_field(:validation_status, object, current_user: user)).to eq('none')
    end
  end

  describe 'normalizedTargetUrl field' do
    it 'is the normalized url of the associated dast_site' do
      normalized_url = DastSiteValidation.get_normalized_url_base(object.dast_site.url)

      expect(resolve_field(:normalized_target_url, object, current_user: user)).to eq(normalized_url)
    end
  end

  describe 'referencedInSecurityPolicies field' do
    it 'is the policies' do
      expect(resolve_field(:referenced_in_security_policies, object, current_user: user)).to eq(object.referenced_in_security_policies)
    end
  end
end
