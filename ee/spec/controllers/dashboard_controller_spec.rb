# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DashboardController do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }

  context 'signed in' do
    before do
      project.add_developer(user)
      sign_in(user)
    end

    describe 'GET issues' do
      it 'does not list test cases' do
        issue = create(:incident, project: project, author: user)
        incident = create(:incident, project: project, author: user)
        create(:quality_test_case, project: project, author: user)

        get :issues, params: { author_id: user.id }

        expect(assigns(:issues)).to match_array([issue, incident])
      end
    end
  end
end
