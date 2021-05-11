# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Group information', :js, :aggregate_failures do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:empty_project) { create(:project, namespace: group) }

  subject(:visit_page) { visit group_path(group) }

  before do
    group.add_owner(user)
    sign_in(user)
  end

  context 'when the default value of "Group information content" preference is used' do
    it 'displays the Details view' do
      visit_page

      page.within(find('.content')) do
        expect(page).to have_content _('Subgroups and projects')
        expect(page).to have_content _('Shared projects')
        expect(page).to have_content _('Archived projects')
      end
    end
  end

  context 'when Security Dashboard view is set as default' do
    before do
      stub_licensed_features(security_dashboard: true)
      enable_namespace_license_check!
    end

    let(:user) { create(:user, group_view: :security_dashboard) }

    context 'and Security Dashboard feature is not available for a group' do
      let(:group) { create(:group_with_plan, plan: :bronze_plan) }

      it 'displays the "Security Dashboard unavailable" empty state' do
        visit_page

        page.within(find('.content')) do
          expect(page).to have_content s_("SecurityReports|Either you don't have permission to view this dashboard or "\
                                       'the dashboard has not been setup. Please check your permission settings '\
                                       'with your administrator or check your dashboard configurations to proceed.')
        end
      end
    end
  end
end
