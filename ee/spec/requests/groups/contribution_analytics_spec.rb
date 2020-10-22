# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'contribution analytics' do
  let(:user) { create(:user) }
  let(:group) { create(:group)}

  before do
    group.add_developer(user)
    login_as(user)
  end

  it 'redirects from -/analytics to -/contribution_analytics' do
    get "/groups/#{group.full_path}/-/analytics"

    expect(response).to redirect_to(group_contribution_analytics_path(group.full_path))
  end
end
