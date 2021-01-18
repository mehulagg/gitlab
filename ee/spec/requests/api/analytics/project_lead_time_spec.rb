# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Analytics::ProjectLeadTime do
  let_it_be(:group) { create(:group, :private) }
  let_it_be(:project) { create(:project, :repository, namespace: group) }
  let_it_be(:anonymous_user) { create(:user) }
  let_it_be(:reporter) { create(:user).tap { |u| project.add_reporter(u) } }

  def make_mr(proj, created_at, merged_at)
    updated_at = merged_at || created_at
    create(:merge_request,
      :unique_branches,
      state: merged_at ? 'merged' : 'opened',
      created_at: created_at,
      updated_at: updated_at,
      source_project: proj,
      target_project: proj).metrics.tap do |metrics|
        # MR metrics are created after the fact by batch processing in a task, simulate that
        # by setting our metrics' created_at time a bit after the MR's last update time.
        metrics_created_at = updated_at + 6.hours
        metrics.update!(
          created_at: metrics_created_at,
          updated_at: metrics_created_at,
          merged_at: merged_at
        )
      end
  end

  let_it_be(:mr_2020_01_01) { make_mr(project, DateTime.new(2020, 1, 1), DateTime.new(2020, 1, 1)) }
  let_it_be(:mr_2020_01_02) { make_mr(project, DateTime.new(2020, 1, 1), DateTime.new(2020, 1, 2)) }
  let_it_be(:mr_2020_01_03) { make_mr(project, DateTime.new(2020, 1, 3), nil) }
  let_it_be(:mr_2020_01_04) { make_mr(project, DateTime.new(2020, 1, 1), DateTime.new(2020, 1, 4)) }
  let_it_be(:mr_2020_01_05) { make_mr(project, DateTime.new(2020, 1, 1), DateTime.new(2020, 1, 5)) }

  let_it_be(:mr_2020_02_01) { make_mr(project, DateTime.new(2020, 2, 1), DateTime.new(2020, 2, 1)) }
  let_it_be(:mr_2020_02_02) { make_mr(project, DateTime.new(2020, 2, 1), DateTime.new(2020, 2, 2)) }
  let_it_be(:mr_2020_02_03) { make_mr(project, DateTime.new(2020, 2, 3), nil) }
  let_it_be(:mr_2020_02_04) { make_mr(project, DateTime.new(2020, 2, 1), DateTime.new(2020, 2, 4)) }
  let_it_be(:mr_2020_02_05) { make_mr(project, DateTime.new(2020, 2, 1), DateTime.new(2020, 2, 5)) }

  let_it_be(:mr_2020_03_01) { make_mr(project, DateTime.new(2020, 3, 1), DateTime.new(2020, 3, 1)) }
  let_it_be(:mr_2020_03_02) { make_mr(project, DateTime.new(2020, 3, 1), DateTime.new(2020, 3, 2)) }
  let_it_be(:mr_2020_03_03) { make_mr(project, DateTime.new(2020, 3, 3), nil) }
  let_it_be(:mr_2020_03_04) { make_mr(project, DateTime.new(2020, 3, 1), DateTime.new(2020, 3, 4)) }
  let_it_be(:mr_2020_03_05) { make_mr(project, DateTime.new(2020, 3, 1), DateTime.new(2020, 3, 5)) }

  let_it_be(:mr_2020_04_01) { make_mr(project, DateTime.new(2020, 4, 1), DateTime.new(2020, 4, 1)) }
  let_it_be(:mr_2020_04_02) { make_mr(project, DateTime.new(2020, 4, 1), DateTime.new(2020, 4, 2)) }
  let_it_be(:mr_2020_04_03) { make_mr(project, DateTime.new(2020, 4, 3), nil) }
  let_it_be(:mr_2020_04_04) { make_mr(project, DateTime.new(2020, 4, 1), DateTime.new(2020, 4, 4)) }
  let_it_be(:mr_2020_04_05) { make_mr(project, DateTime.new(2020, 4, 1), DateTime.new(2020, 4, 5)) }

  let(:dora4_analytics_enabled) { true }
  let(:current_user) { reporter }
  let(:params) { { from: Time.now, to: Time.now, interval: "all" } }
  let(:path) { api("/projects/#{project.id}/analytics/lead_time", current_user) }
  let(:request) { get path, params: params }
  let(:request_time) { nil }

  before do
    stub_licensed_features(dora4_analytics: dora4_analytics_enabled)

    if request_time
      travel_to(request_time) { request }
    else
      request
    end
  end

  context 'when user has access to the project' do
    it 'returns `ok`' do
      expect(response).to have_gitlab_http_status(:ok)
    end
  end

  context 'with params: from 2017 to 2019' do
    let(:params) { { from: DateTime.new(2017), to: DateTime.new(2019) } }

    it 'returns `bad_request` with expected message' do
      expect(response.parsed_body).to eq({
        "message" => "Date range is greater than 91 days"
      })
    end
  end

  context 'with params: from 2019 to 2017' do
    let(:params) do
      { from: DateTime.new(2019), to: DateTime.new(2017) }
    end

    it 'returns `bad_request` with expected message' do
      expect(response.parsed_body).to eq({
        "message" => "Parameter `to` is before the `from` date"
      })
    end
  end

  context 'with params: from 2020/04/02 to request time' do
    let(:request_time) { DateTime.new(2020, 4, 4) }
    let(:params) { { from: DateTime.new(2020, 4, 2) } }

    it 'returns the expected lead times' do
      expect(response.parsed_body).to eq([{
        "from" => "2020-04-02",
        "to" => "2020-04-04",
        "value" => 1440
      }])
    end
  end

  context 'with params: from 2020/02/01 to 2020/04/01 by all' do
    let(:params) do
      {
        from: DateTime.new(2020, 2, 1),
        to: DateTime.new(2020, 4, 1),
        interval: "all"
      }
    end

    it 'returns the expected lead times' do
      expect(response.parsed_body).to eq([{
          "from" => "2020-02-01",
          "to" => "2020-04-01",
          "value" => 2880
        }])
    end
  end

  context 'with params: from 2020/02/01 to 2020/04/01 by month' do
    let(:params) do
      {
        from: DateTime.new(2020, 2, 1),
        to: DateTime.new(2020, 4, 1),
        interval: "monthly"
      }
    end

    it 'returns the expected lead times' do
      expect(response.parsed_body).to eq([
        { "from" => "2020-02-01", "to" => "2020-03-01", "value" => 2880 },
        { "from" => "2020-03-01", "to" => "2020-04-01", "value" => 2880 }
      ])
    end
  end

  context 'with params: from 2020/02/01 to 2020/04/01 by day' do
    let(:params) do
      {
        from: DateTime.new(2020, 2, 1),
        to: DateTime.new(2020, 4, 1),
        interval: "daily"
      }
    end

    it 'returns the expected lead times' do
      expect(response.parsed_body).to eq([
        { "from" => "2020-02-01", "to" => "2020-02-02", "value" => 0 },
        { "from" => "2020-02-02", "to" => "2020-02-03", "value" => 1440 },
        { "from" => "2020-02-04", "to" => "2020-02-05", "value" => 4320 },
        { "from" => "2020-02-05", "to" => "2020-02-06", "value" => 5760 },
        { "from" => "2020-03-01", "to" => "2020-03-02", "value" => 0 },
        { "from" => "2020-03-02", "to" => "2020-03-03", "value" => 1440 },
        { "from" => "2020-03-04", "to" => "2020-03-05", "value" => 4320 },
        { "from" => "2020-03-05", "to" => "2020-03-06", "value" => 5760 }
      ])
    end
  end

  context 'with params: invalid interval' do
    let(:params) do
      {
        from: DateTime.new(2020, 1),
        to: DateTime.new(2020, 2),
        interval: "invalid"
      }
    end

    it 'returns `bad_request`' do
      expect(response).to have_gitlab_http_status(:bad_request)
    end
  end

  context 'with params: missing from' do
    let(:params) { { to: DateTime.new(2019), interval: "all" } }

    it 'returns `bad_request`' do
      expect(response).to have_gitlab_http_status(:bad_request)
    end
  end

  context 'when user does not have access to the project' do
    let(:current_user) { anonymous_user }

    it 'returns `not_found`' do
      expect(response).to have_gitlab_http_status(:not_found)
    end
  end

  context 'when feature is not available in plan' do
    let(:dora4_analytics_enabled) { false }

    context 'when user has access to the project' do
      it 'returns `forbidden`' do
        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end

    context 'when user does not have access to the project' do
      let(:current_user) { anonymous_user }

      it 'returns `not_found`' do
        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end
end
