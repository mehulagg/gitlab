# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Dashboard merge requests' do
  let(:user) { create(:user) }
  let(:page_path) { merge_requests_dashboard_path }

  it_behaves_like 'dashboard gold trial callout'
end
