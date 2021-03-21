# frozen_string_literal: true

module API
  class UsageDataNonSqlMetrics < ::API::Base
    before { authenticate! }

    feature_category :usage_ping

    namespace 'usage_data' do
      before do
        forbidden!('Invalid CSRF token is provided') unlss verified_request?
      end

      desc 'Get Non SQL usage ping metrics' do
        detail 'This feature was introduced in GitLab 13.11.0'
      end

      get 'non_sql_metrics' do
        data = Gitlab::UsageDataNonSqlMetrics.data

        present data
      end
    end
  end
end
