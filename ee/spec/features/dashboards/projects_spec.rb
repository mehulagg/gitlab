require 'spec_helper'

describe 'Dashboard projects' do
  let(:user) { create(:user) }
  let(:page_path) { dashboard_projects_path }

  it_behaves_like 'gold trial callout'
end
