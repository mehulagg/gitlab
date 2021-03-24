# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['License'] do
  let_it_be(:admin) { create(:admin) }
  let_it_be(:licensee) do
    {
      'Name' => 'Example User',
      'Email' => 'user@example.com',
      'Company' => 'Example Inc.',
      'Address' => 'Example Street 1, 12345 Example City'
    }
  end

  let_it_be(:license) { create_current_license(licensee: licensee) }

  let(:fields) do
    %i[
      id plan last_sync started renews name email company address
      users_in_subscription billable_users maximum_users users_over_subscription
    ]
  end

  def result_as_json
    GitlabSchema.execute(query, context: { current_user: admin }).as_json
  end

  it { expect(described_class.graphql_name).to eq('License') }

  it { expect(described_class).to have_graphql_fields(fields) }

  describe "#plan" do
    let(:query) do
      %(
        {
          license {
            plan
          }
        }
      )
    end

    it 'returns the capitalized plan' do
      expect(result_as_json['data']['license']['plan']).to eq('Starter')
    end
  end

  describe "#name" do
    let(:query) do
      %(
        {
          license {
            name
          }
        }
      )
    end

    it 'returns the email of the licensee' do
      expect(result_as_json['data']['license']['name']).to eq('User Example')
    end
  end

  describe "#email" do
    let(:query) do
      %(
        {
          license {
            email
          }
        }
      )
    end

    it 'returns the email of the licensee' do
      expect(result_as_json['data']['license']['email']).to eq('user@example.com')
    end
  end

  describe "#company" do
    let(:query) do
      %(
        {
          license {
            company
          }
        }
      )
    end

    it 'returns the company of the licensee' do
      expect(result_as_json['data']['license']['company']).to eq('Example Inc.')
    end
  end

  describe "#address" do
    let(:query) do
      %(
        {
          license {
            address
          }
        }
      )
    end

    it 'returns the address of the licensee' do
      expect(result_as_json['data']['license']['address']).to eq('Example Street 1, 12345 Example City')
    end
  end

  describe "#users_in_subscription" do
    let(:query) do
      %(
        {
          license {
            users_in_subscription
          }
        }
      )
    end

    context 'when active_user_count is set' do
      it 'returns the number of users paid for in the license' do
        create_current_license(licensee: licensee, restrictions: { active_user_count: 10 })

        expect(result_as_json['data']['license']['users_in_subscription']).to eq('Starter')
      end
    end

    it 'returns the number of users paid for in the license' do
      expect(result_as_json['data']['license']['users_in_subscription']).to be_nil
    end
  end

  describe "#users_over_subscription" do
    let(:query) do
      %(
        {
          license {
            users_over_subscription
          }
        }
      )
    end

    context 'when license is for a trial' do
      it 'returns 0' do
        create_current_license(licensee: licensee, restrictions: { trial: true })

        expect(result_as_json['data']['license']['users_over_subscription']).to eq(0)
      end
    end

    it 'returns the number of users over the paid users in the license' do
      create(:historical_data, active_user_count: 15)
      create_current_license(licensee: licensee, restrictions: { active_user_count: 10 })

      expect(result_as_json['data']['license']['users_over_subscription']).to eq(5)
    end
  end
end
