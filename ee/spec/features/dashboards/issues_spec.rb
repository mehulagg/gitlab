require 'spec_helper'

describe 'Dashboard issues' do
  let(:user) { create(:user) }
  let(:page_path) { issues_dashboard_path }

  it_behaves_like 'gold trial callout'
end
