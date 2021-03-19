# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Experiments do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, name: 'GitLab.com', path: 'gitlab-com') }

  describe 'GET /experiments' do
    context 'when on .com' do
      let(:experiments) do
        {
          experiment_1: {
            tracking_category: 'something'
          },
          experiment_2: {
            tracking_category: 'something_else'
          }
        }
      end

      before do
        skip_feature_flags_yaml_validation
        skip_default_enabled_yaml_check
        stub_const('Gitlab::Experimentation::EXPERIMENTS', experiments)
        Feature.enable_percentage_of_time('experiment_1_experiment_percentage', 10)
        Feature.disable('experiment_2_experiment_percentage')
        allow(Gitlab).to receive(:com?).and_return(true)
      end

      it 'returns a 401 for anonymous users' do
        get api('/experiments')

        expect(response).to have_gitlab_http_status(:unauthorized)
      end

      it 'returns a 403 for users' do
        get api('/experiments', user)

        expect(response).to have_gitlab_http_status(:forbidden)
      end

      it 'returns a 403 for non human users' do
        bot = create(:user, :bot)
        group.add_developer(bot)

        get api('/experiments', bot)

        expect(response).to have_gitlab_http_status(:forbidden)
      end

      it 'returns the feature list for gitlab team members' do
        expected_experiments = [
          {
            'key' => 'experiment_1',
            'enabled' => true
          },
          {
            'key' => 'experiment_2',
            'enabled' => false
          }
        ]
        group.add_developer(user)

        get api('/experiments', user)

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response).to match_array(expected_experiments)
      end
    end

    context 'when not .com' do
      before do
        allow(Gitlab).to receive(:com?).and_return(false)
      end

      it 'returns a 403 for users' do
        group.add_developer(user)

        get api('/experiments', user)

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end
  end
end
