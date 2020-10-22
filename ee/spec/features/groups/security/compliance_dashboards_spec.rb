# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Compliance Dashboard', :js do
  let_it_be(:current_user) { create(:user) }
  let_it_be(:user) { current_user }
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :repository, :public, namespace: group) }

  before do
    stub_licensed_features(group_level_compliance_dashboard: true)
    group.add_owner(user)
    sign_in(user)
    visit group_security_compliance_dashboard_path(group)
  end

  context 'when there are no merge requests' do
    it 'shows an empty state' do
      expect(page).to have_selector('.empty-state')
    end
  end

  context 'when there are merge requests' do
    let_it_be(:merge_request) { create(:merge_request, source_project: project, state: :merged) }

    before_all do
      create(:event, :merged, project: project, target: merge_request, author: user, created_at: 10.minutes.ago)
    end

    it 'shows merge requests with details' do
      expect(page).to have_link(merge_request.title)
      expect(page).to have_content('merged 10 minutes ago')
      expect(page).to have_content('no approvers')
    end
  end
end
