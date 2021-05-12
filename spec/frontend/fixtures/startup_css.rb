# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Startup CSS fixtures', type: :controller do
  include JavaScriptFixturesHelpers

  let(:project) { create(:project, :repository, description: 'Code and stuff', avatar: fixture_file_upload('spec/fixtures/dk.png', 'image/png')) }
  let(:user) { project.owner }

  render_views

  before(:all) do
    clean_frontend_fixtures('startup_css/')
  end

  before do
    sign_in(user)
  end

  describe ProjectsController, '(JavaScript fixtures)', type: :controller do
    it 'startup_css/project-overview.html' do
      get :show, params: {
        namespace_id: project.namespace.to_param,
        id: project
      }

      expect(response).to be_successful
    end
  end
end
