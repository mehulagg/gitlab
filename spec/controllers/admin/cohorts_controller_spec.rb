# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Admin::CohortsController do
  let(:user) { create(:admin) }

  before do
    sign_in(user)
  end

  it 'redirects to Overview->Users' do
    get :index

    expect(response).to redirect_to(admin_cohorts_path)
  end
end
