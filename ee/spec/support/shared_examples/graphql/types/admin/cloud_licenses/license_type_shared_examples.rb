# frozen_string_literal: true

RSpec.shared_examples_for 'license type fields' do |keys|
  context 'with license type fields' do
    let(:license_fields) do
      %w[id type plan name email company starts_at expires_at block_changes_at activated_at users_in_license_count]
    end

    it { expect(described_class).to include_graphql_fields(*license_fields) }
  end
end
