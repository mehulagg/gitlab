# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['CurrentLicense'], :enable_admin_mode do
  let_it_be(:admin) { create(:admin) }
  let_it_be(:licensee) do
    {
      'Name' => 'User Example',
      'Email' => 'user@example.com',
      'Company' => 'Example Inc.',
      'Address' => 'Example Street 1, 12345 Example City'
    }
  end

  let_it_be(:license) { create_current_license(licensee: licensee) }

  let(:fields) do
    %w[
      id last_sync renews address
      billable_users maximum_users users_over_subscription
    ]
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

  describe "#address" do
    it 'returns the address of the licensee' do
      result_as_json = query_field('address')

      expect(result_as_json['data']['currentLicense']['address']).to eq('Example Street 1, 12345 Example City')
    end
  end

  describe "#users_over_subscription" do
    context 'when license is for a trial' do
      it 'returns 0' do
        create_current_license(licensee: licensee, restrictions: { trial: true })

        result_as_json = query_field('usersOverSubscription')

        expect(result_as_json['data']['currentLicense']['usersOverSubscription']).to eq(0)
      end
    end

    it 'returns the number of users over the paid users in the license' do
      create(:historical_data, active_user_count: 15)
      create_current_license(licensee: licensee, restrictions: { active_user_count: 10 })

      result_as_json = query_field('usersOverSubscription')

      expect(result_as_json['data']['currentLicense']['usersOverSubscription']).to eq(5)
    end
  end
end
