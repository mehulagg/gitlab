# frozen_string_literal: true

module API
  class UsageDataQueries < ::API::Base
    before { authenticate! }

    feature_category :usage_ping

    namespace 'usage_data' do
      before do
        forbidden!('Invalid CSRF token is provided') unless verified_request?
      end

      desc 'Get raw SQL queries for usage data SQL metrics' do
        detail 'This feature was introduced in GitLab 13.11.'
      end

      get 'usage_data_queries' do
        # TODO
      end
    end
  end
end
