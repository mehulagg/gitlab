# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['CurrentLicense'], :enable_admin_mode do
  let_it_be(:admin) { create(:admin) }
  let_it_be(:licensee) do
    {
      'Name' => 'User Example',
      'Email' => 'user@example.com',
      'Company' => 'Example Inc.'
    }
  end

  let_it_be(:license) { create_current_license(licensee: licensee, type: License::CLOUD_LICENSE_TYPE) }

  let(:fields) do
    %w[last_sync billable_users_count maximum_user_count users_over_license_count]
  end

  def query(field_name)
    %(
      {
        currentLicense {
          #{field_name}
        }
      }
    )
  end

  def query_field(field_name)
    GitlabSchema.execute(query(field_name), context: { current_user: admin }).as_json
  end

  before do
    stub_application_setting(cloud_license_enabled: true)
  end

  it { expect(described_class.graphql_name).to eq('CurrentLicense') }
  it { expect(described_class).to include_graphql_fields(*fields) }

  include_examples 'license type fields', %w[data currentLicense]

  describe "#users_over_license_count" do
    context 'when license is for a trial' do
      it 'returns 0' do
        create_current_license(licensee: licensee, restrictions: { trial: true })

        result_as_json = query_field('usersOverLicenseCount')

        expect(result_as_json['data']['currentLicense']['usersOverLicenseCount']).to eq(0)
      end
    end

    it 'returns the number of users over the paid users in the license' do
      create(:historical_data, active_user_count: 15)
      create_current_license(licensee: licensee, restrictions: { active_user_count: 10 })

      result_as_json = query_field('usersOverLicenseCount')

      expect(result_as_json['data']['currentLicense']['usersOverLicenseCount']).to eq(5)
    end
  end
end
