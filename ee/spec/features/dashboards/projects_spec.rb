# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Dashboard projects' do
  let(:user) { create(:user) }
  let(:page_path) { dashboard_projects_path }

  it_behaves_like 'dashboard gold trial callout'
end
