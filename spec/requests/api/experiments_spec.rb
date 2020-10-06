# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Experiments do
  let_it_be(:user) { create(:user) }
  let_it_be(:admin) { create(:admin) }

  describe 'GET /experiments' do
    let(:experiments) do
      {
        experiment_1: {
          tracking_category: 'something',
          environment: true
        },
        experiment_2: {
          tracking_category: 'something_else'
        }
      }
    end

    let(:expected_experiments) do
      [
        {
          'key' => 'experiment_1',
          'enabled' => true
        },
        {
          'key' => 'experiment_2',
          'enabled' => false
        }
      ]
    end

    before do
      stub_const('Gitlab::Experimentation::EXPERIMENTS', experiments)
      Feature.enable_percentage_of_time('experiment_1_experiment_percentage', 10)
      Feature.disable('experiment_2_experiment_percentage')
    end

    it 'returns a 401 for anonymous users' do
      get api('/experiments')

      expect(response).to have_gitlab_http_status(:unauthorized)
    end

    it 'returns a 403 for users' do
      get api('/experiments', user)

      expect(response).to have_gitlab_http_status(:forbidden)
    end

    it 'returns the feature list for admins' do
      get api('/experiments', admin)

      expect(response).to have_gitlab_http_status(:ok)
      expect(json_response).to match_array(expected_experiments)
    end
  end
end
