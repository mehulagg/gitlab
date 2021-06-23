# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::Analytics::DevopsAdoptionController do
  let_it_be(:current_user) { create(:user) }
  let_it_be(:group) { create :group }

  before do
    sign_in(current_user)

    stub_licensed_features(group_level_devops_adoption: true)
  end

  describe 'GET show' do
    subject do
      get group_analytics_devops_adoption_path(group)
    end

    before do
      group.add_maintainer(current_user)
    end

    it 'renders the devops adoption page' do
      subject

      expect(response).to render_template :show
    end

    context 'when the feature is not available' do
      before do
        stub_licensed_features(group_level_devops_adoption: false)
      end

      it 'renders forbidden' do
        subject

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end

    it 'tracks devops_adoption usage event' do
      expect(Gitlab::UsageDataCounters::HLLRedisCounter)
        .to receive(:track_event).with('users_viewing_analytics_group_devops_adoption', values: kind_of(String))

      subject
    end
  end
end
