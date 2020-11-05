# frozen_string_literal: true

RSpec.describe QA::EE::Scenario::Test::Integration::GroupSAML do
  describe '#perform' do
    it_behaves_like 'a QA scenario class' do
      let(:tags) { [:group_saml] }
    end
  end
end
