# frozen_string_literal: true

RSpec.shared_examples_for 'DevOps Adoption top level errors' do
  context 'when the user is not an admin' do
    let(:current_user) { create(:user) }

    it_behaves_like 'a mutation that returns top-level errors', errors: [described_class::ADMIN_MESSAGE]
  end

  context 'when the feature is not available' do
    let(:current_user) { admin }

    before do
      stub_licensed_features(instance_level_devops_adoption: false)
    end

    it_behaves_like 'a mutation that returns top-level errors', errors: [described_class::FEATURE_UNAVAILABLE_MESSAGE]
  end
end
