# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'DORA Metrics (JavaScript fixtures)' do
  include ApiHelpers
  include JavaScriptFixturesHelpers

  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:reporter) { create(:user).tap { |u| project.add_reporter(u) } }
  let_it_be(:environment) { create(:environment, project: project, name: 'production') }

  before_all do
    [
      { date: '2015-06-01', value: 1 },
      { date: '2015-06-25', value: 1 },
      { date: '2015-06-30', value: 3 },
      { date: '2015-07-01', value: 1 },
      { date: '2015-07-03', value: 1 }
    ].each do |data_point|
      create(:dora_daily_metrics, deployment_frequency: data_point[:value], environment: environment, date: data_point[:date])
    end
  end

  before do
    stub_licensed_features(dora4_analytics: true)
    sign_in(reporter)
  end

  after(:all) do
    remove_repository(project)
  end

  describe API::Dora::Metrics, type: :request do
    before(:all) do
      clean_frontend_fixtures('api/dora/metrics')
    end

    describe 'deployment frequency' do
      let(:shared_params) do
        {
          metric: 'deployment_frequency',
          end_date: Date.tomorrow.beginning_of_day,
          interval: 'daily'
        }
      end

      def make_request(additional_query_params:)
        params = shared_params.merge(additional_query_params)
        get api("/projects/#{project.id}/dora/metrics?#{params.to_query}", reporter)
      end

      it 'api/dora/metrics/daily_deployment_frequencies_for_last_week.json' do
        make_request(additional_query_params: { start_date: 1.week.ago })
        expect(response).to be_successful
      end

      it 'api/dora/metrics/daily_deployment_frequencies_for_last_month.json' do
        make_request(additional_query_params: { start_date: 1.month.ago })
        expect(response).to be_successful
      end

      it 'api/dora/metrics/daily_deployment_frequencies_for_last_90_days.json' do
        make_request(additional_query_params: { start_date: 90.days.ago })
        expect(response).to be_successful
      end
    end
  end
end
