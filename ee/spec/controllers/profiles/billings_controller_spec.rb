# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Profiles::BillingsController do
  let_it_be(:user) { create(:user) }

  describe 'GET #index' do
    before do
      sign_in(user)
      stub_application_setting(check_namespace_plan: true)
      allow(Gitlab).to receive(:com?) { true }
      allow_next_instance_of(FetchSubscriptionPlansService) do |instance|
        allow(instance).to receive(:execute)
      end
      allow(controller).to receive(:track_experiment_event)
    end

    def get_index
      get :index
    end

    subject { response }

    it 'renders index with 200 status code' do
      get_index

      is_expected.to have_gitlab_http_status(:ok)
      is_expected.to render_template(:index)
    end

    it 'fetch subscription plans data from customers.gitlab.com' do
      data = double
      expect_next_instance_of(FetchSubscriptionPlansService) do |instance|
        expect(instance).to receive(:execute).and_return(data)
      end

      get_index

      expect(assigns(:plans_data)).to eq(data)
    end

    it 'tracks the page view for the contact_sales_btn_in_app experiment' do
      expect(controller).to receive(:track_experiment_event).with(:contact_sales_btn_in_app, 'page_view:billing_plans:profile')

      get_index
    end

    it 'records user for the contact_sales_btn_in_app experiment' do
      expect(controller).to receive(:record_experiment_user).with(:contact_sales_btn_in_app)

      get_index
    end
  end
end
