# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Admin::DevOpsReportController do
  describe 'show_adoption?' do
    it "is false if license feature 'devops_adoption' is disabled" do
      expect(controller.show_adoption?).to be false
    end

    context "'devops_adoption' license feature is enabled" do
      before do
        stub_licensed_features(devops_adoption: true)
      end

      it 'is true if there are any enabled_namespaces' do
        create(:devops_adoption_enabled_namespace)

        expect(controller.show_adoption?).to be true
      end

      it "is true if the 'devops_adoption_feature' feature is enabled" do
        expect(controller.show_adoption?).to be true
      end

      it "is false if the 'devops_adoption_feature' feature is disabled" do
        stub_feature_flags(devops_adoption_feature: false)

        expect(controller.show_adoption?).to be false
      end
    end
  end

  describe '#show' do
    let(:user) { create(:admin) }

    before do
      sign_in(user)
    end

    shared_examples 'tracks usage event' do |event, tab|
      it "tracks #{event} usage event for #{tab}" do
        expect(Gitlab::UsageDataCounters::HLLRedisCounter)
          .to receive(:track_event).with(event, values: kind_of(String))

        get :show, params: { tab: tab }, format: :html
      end
    end

    context 'when browsing to specific tabs' do
      ['', 'dev', 'sec', 'ops'].each do |tab|
        it_behaves_like 'tracks usage event', 'i_analytics_dev_ops_adoption', tab
      end

      it_behaves_like 'tracks usage event', 'i_analytics_dev_ops_score', 'devops-score'
    end
  end
end
