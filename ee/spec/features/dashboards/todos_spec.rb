# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Dashboard todos' do
  let_it_be(:user) { create(:user) }

  let(:page_path) { dashboard_todos_path }

  it_behaves_like 'dashboard ultimate trial callout'
end
