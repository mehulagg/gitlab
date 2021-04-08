# frozen_string_literal: true

RSpec.shared_examples_for 'license type fields' do |keys|
  context 'with license type fields' do
    let(:license_fields) do
      %w[id type plan name email company starts_at expires_at activated_at users_in_license]
    end

    it { expect(described_class).to include_graphql_fields(*license_fields) }

    describe "#type" do
      context 'when license is a legacy license' do
        it 'returns the type' do
          License.delete_all
          create(:license, data: create(:gitlab_license, licensee: licensee).export)

          result_as_json = query_field('type')

          expect(result_as_json.dig(*keys)['type']).to eq('legacy')
        end
      end

      it 'returns the type' do
        result_as_json = query_field('type')

        expect(result_as_json.dig(*keys)['type']).to eq('cloud')
      end
    end

    describe "#plan" do
      it 'returns the capitalized plan' do
        result_as_json = query_field('plan')

        expect(result_as_json.dig(*keys)['plan']).to eq('Starter')
      end
    end

    describe "#users_in_license" do
      context 'when active_user_count is set' do
        it 'returns the number of paid users in the license' do
          create_current_license(licensee: licensee, restrictions: { active_user_count: 10 })

          result_as_json = query_field('usersInLicense')

          expect(result_as_json.dig(*keys)['usersInLicense']).to eq(10)
        end
      end

      it 'returns the number of paid users in the license' do
        result_as_json = query_field('usersInLicense')

        expect(result_as_json.dig(*keys)['usersInLicense']).to be_nil
      end
    end
  end
end
