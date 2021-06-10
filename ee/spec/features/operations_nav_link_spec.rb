# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Operations dropdown navbar EE' do
  include Spec::Support::Helpers::Features::TopNavSpecHelpers

  let(:user) { create(:user) }
  let(:project) { create(:project) }

  shared_examples 'combined_menu: feature flag examples' do
    before do
      project.add_maintainer(user)
      sign_in(user)

      stub_licensed_features(operations_dashboard: true)

      visit project_issues_path(project)
    end

    it 'has an `Operations` link' do
      open_top_nav

      expect(page).to have_link('Operations', href: operations_path)
    end

    it 'has an `Environments` link' do
      open_top_nav

      expect(page).to have_link('Environments', href: operations_environments_path)
    end
  end

  context 'with combined_menu feature flag on', :js do
    let(:needs_rewrite_for_combined_menu_flag_on) { true }

    before do
      stub_feature_flags(combined_menu: true)
    end

    it_behaves_like 'combined_menu: feature flag examples'
  end

  context 'with combined_menu feature flag off' do
    let(:needs_rewrite_for_combined_menu_flag_on) { false }

    before do
      stub_feature_flags(combined_menu: false)
    end

    it_behaves_like 'combined_menu: feature flag examples'
  end
end
