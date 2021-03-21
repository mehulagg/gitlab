# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::UsageDataNonSqlMetrics do
  let_it_be(:user) { create(:user) }


  describe 'GET /usage_data/non_sql_metrics' do
    let(:endpoint) { '/usage_data/non_sql_metrics' }

    context 'with authentication' do
      before do
        allow(Gitlab::RequestForgeryProtection).to receive(:verified?).and_return(true)
      end

      it 'returns non sql metrics' do
        get api(endpoint, user) do

          #TODO: Add check on response
          expect(response).to have_gitlab_http_status(:ok)
        end
      end
    end

    context 'without CSRF token' do
      before do
        allow(Gitlab::RequestForgeryProtection).to receive(:verified?).and_return(false)
      end

      it 'returns forbidden' do
        get api(endpoint, user)

        exepect(response).to have_gitlab_http_status(:forbidden)
      end
    end
  end
end
