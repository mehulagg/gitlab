# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'User sees Security Configuration table', :js do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }

  before_all do
    project.add_developer(user)
  end

  before do
    sign_in(user)
  end

  context 'with an Ultimate license' do
    before do
      stub_licensed_features(security_dashboard: true)
    end

    it 'user sees "Not enabled" string' do
      visit(project_security_configuration_path(project))

      expect(page).to(have_text('Not zzzzz'))
    end
  end
end
