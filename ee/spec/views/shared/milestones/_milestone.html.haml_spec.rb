# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'shared/milestones/_milestone.html.haml' do
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:user) { create(:user).tap { |user| project.add_maintainer(user) } }
  let_it_be(:releases) { create_list(:release, 4, project: project) }
  let_it_be(:milestone) { nil }

  let(:more_text) { '1 more release' }
  let(:link_href) { project_releases_path(project) }

  before do
    stub_licensed_features(group_milestone_project_releases: true)

    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:milestone).and_return(milestone)
    allow(view).to receive(:issues_path).and_return('path/to/issues')
    allow(view).to receive(:merge_requests_path).and_return('path/to/merge_requests')
  end

  context 'when a milestone is associated to a lot of releases' do
    context 'when viewing a project milestone' do
      let(:milestone) { create(:milestone, project: project, releases: releases) }

      before do
        assign(:project, project)
      end

      it 'renders "1 more release" as a link to the project\'s Releases page' do
        render

        expect(rendered).to have_link(more_text, href: link_href)
      end
    end

    context 'when viewing a group milestone' do
      let(:milestone) { create(:milestone, group: group, releases: releases) }

      before do
        assign(:group, group)
      end

      it 'renders "1 more release" as plain text instead of as a link', :aggregate_failures do
        render

        expect(rendered).not_to have_link(more_text, href: link_href)
        expect(rendered).to have_content(more_text)
      end
    end
  end
end
