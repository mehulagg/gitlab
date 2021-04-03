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

      it 'is true if there are any segments' do
        create(:devops_adoption_segment)

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

    context 'when devops_adoption tab selected' do
      it 'tracks devops_adoption usage event' do
        expect(Gitlab::UsageDataCounters::HLLRedisCounter)
          .to receive(:track_event).with('i_analytics_dev_ops_adoption', values: kind_of(String))

        get :show, params: { tab: 'devops-adoption' }, format: :html
      end
    end
  end
end
