# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Admin::DashboardController do
  describe '#index' do
    render_views

    it "allows an admin user to access the page" do
      sign_in(create(:user, :admin))

      get :index

      expect(response).to have_gitlab_http_status(:ok)
    end

    it "does not allow an auditor user to access the page" do
      sign_in(create(:user, :auditor))

      get :index

      expect(response).to have_gitlab_http_status(:not_found)
    end

    it "does not allow a regular user to access the page" do
      sign_in(create(:user))

      get :index

      expect(response).to have_gitlab_http_status(:not_found)
    end

    it 'shows the license breakdown' do
      sign_in(create(:user, :admin))

      get :index

      expect(response.body).to include('Users in License')
    end

    context 'when the user count is high' do
      let(:counts) do
        described_class::COUNTED_ITEMS.each_with_object({}) { |model, hash| hash[model] = described_class::LICENSE_BREAKDOWN_USER_LIMIT + 1 }
      end

      before do
        expect(Gitlab::Database::Count).to receive(:approximate_counts).and_return(counts)

        sign_in(create(:admin))
      end

      it 'hides the license breakdown' do
        get :index

        expect(response.body).not_to include('Users in License')
      end
    end
  end
end
