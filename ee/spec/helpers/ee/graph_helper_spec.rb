# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::GraphHelper do
  let_it_be(:current_user) { create(:user) }
  let(:project) { create(:project, :private) }
  let(:is_feature_licensed) { true }
  let(:is_user_authorized) { true }

  before do
    stub_licensed_features(dora4_analytics: is_feature_licensed)
    self.instance_variable_set(:@current_user, current_user)
    self.instance_variable_set(:@project, project)
    allow(self).to receive(:can?).with(current_user, :read_dora4_analytics, project).and_return(is_user_authorized)
  end

  describe '#should_render_deployment_frequency_charts' do
    let(:is_flag_enabled) { true }

    before do
      stub_feature_flags(deployment_frequency_charts: is_flag_enabled)
    end

    shared_examples 'returns true' do
      it { expect(should_render_deployment_frequency_charts).to be(true) }
    end

    shared_examples 'returns false' do
      it { expect(should_render_deployment_frequency_charts).to be(false) }
    end

    it_behaves_like 'returns true'

    context 'when the feature is not available' do
      let(:is_feature_licensed) { false }

      it_behaves_like 'returns false'
    end

    context 'when the feature flag is disabled' do
      let(:is_flag_enabled) { false }

      it_behaves_like 'returns false'
    end

    context 'when the user does not have permission' do
      let(:is_user_authorized) { false }

      it_behaves_like 'returns false'
    end
  end

  describe '#should_render_lead_time_charts' do
    shared_examples 'returns true' do
      it { expect(should_render_lead_time_charts).to be(true) }
    end

    shared_examples 'returns false' do
      it { expect(should_render_lead_time_charts).to be(false) }
    end

    it_behaves_like 'returns true'

    context 'when the feature is not available' do
      let(:is_feature_licensed) { false }

      it_behaves_like 'returns false'
    end

    context 'when the user does not have permission' do
      let(:is_user_authorized) { false }

      it_behaves_like 'returns false'
    end
  end
end
