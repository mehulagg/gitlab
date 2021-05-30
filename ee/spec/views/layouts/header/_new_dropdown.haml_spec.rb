# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'layouts/header/_new_dropdown' do
  let_it_be(:user) { create(:user) }

  context 'group-specific links' do
    let_it_be(:group) { create(:group) }

    before do
      allow(view).to receive(:current_user).and_return(user)

      assign(:group, group)
    end

    it 'does not have "New epic" link' do
      render

      expect(rendered).not_to have_link('New epic', href: new_group_epic_path(group))
    end

    context 'as a Group owner' do
      before do
        group.add_owner(user)
      end

      context 'with the epics license' do
        before do
          stub_licensed_features(epics: true)
        end

        it 'has a "New epic" link' do
          render

          expect(rendered).to have_link('New epic', href: new_group_epic_path(group))
        end
      end
    end
  end

  context 'refactor pin' do
    let_it_be(:group) { create(:group) }
    let_it_be(:project) { create(:project) }
    let_it_be(:tracking_label) { 'tracking_label_test' }

    def clean_str(str)
      str.strip.gsub(/[\r\n]{2,}/, "\n")
    end

    before do
      stub_licensed_features(epics: true)

      allow(view).to receive(:current_user).and_return(user)
      allow(view).to receive(:tracking_label).and_return('tracking_label')
      allow(view).to receive(:experiment_tracking_category_and_group) do |key|
        "tracking_category_and_group_#{key}"
      end

      group.add_owner(user)
      project.add_maintainer(user)
    end

    context 'with experiment false' do
      it 'matches snapshot with project' do
        assign(:project, project)

        render

        snapshot = <<-EOF
<li class="header-new dropdown" data-track-event="click_dropdown" data-track-experiment="new_repo" data-track-label="new_dropdown">
<a class="header-new-dropdown-toggle has-tooltip qa-new-menu-toggle" id="js-onboarding-new-project-link" title="New..." ref="tooltip" aria-label="New..." data-toggle="dropdown" data-placement="bottom" data-container="body" data-display="static" href="/projects/new"><svg class="s16" data-testid="plus-square-icon"><use xlink:href="/assets/icons-6d7d4be41eac996c72b30eac2f28399ac8c6eda840a6fe8762fc1b84b30d5a2d.svg#plus-square"></use></svg>
<svg class="s16 caret-down" data-testid="chevron-down-icon"><use xlink:href="/assets/icons-6d7d4be41eac996c72b30eac2f28399ac8c6eda840a6fe8762fc1b84b30d5a2d.svg#chevron-down"></use></svg>
</a><div class="dropdown-menu dropdown-menu-right dropdown-extended-height">
<ul>
<li class="dropdown-bold-header">
This project
</li>
<li><a data-track-event="click_link_new_issue" data-track-label="plus_menu_dropdown" href="/namespace1/project1/-/issues/new">New issue</a></li>
<li><a data-track-event="click_link_new_mr" data-track-label="plus_menu_dropdown" href="/namespace1/project1/-/merge_requests/new">New merge request</a></li>
<li><a data-track-event="click_link_new_snippet_project" data-track-label="plus_menu_dropdown" href="/namespace1/project1/-/snippets/new">New snippet</a></li>

<li class="divider"></li>
<li class="dropdown-bold-header">
GitLab
</li>
<li><a class="qa-global-new-project-link" data-track-experiment="new_repo" data-track-event="click_link_new_project" data-track-label="plus_menu_dropdown" href="/projects/new">New project</a></li>
<li><a data-track-event="click_link_new_group" data-track-label="plus_menu_dropdown" href="/groups/new">New group</a></li>
<li><a class="qa-global-new-snippet-link" data-track-event="click_link_new_snippet_parent" data-track-label="plus_menu_dropdown" href="/-/snippets/new">New snippet</a></li>
</ul>
</div>
</li>
        EOF

        expect(clean_str(rendered)).to eql(clean_str(snapshot))
      end

      it 'matches snapshot with group' do
        assign(:group, group)

        render

        snapshot = <<-EOF
<li class="header-new dropdown" data-track-event="click_dropdown" data-track-experiment="new_repo" data-track-label="new_dropdown">
<a class="header-new-dropdown-toggle has-tooltip qa-new-menu-toggle" id="js-onboarding-new-project-link" title="New..." ref="tooltip" aria-label="New..." data-toggle="dropdown" data-placement="bottom" data-container="body" data-display="static" href="/projects/new"><svg class="s16" data-testid="plus-square-icon"><use xlink:href="/assets/icons-6d7d4be41eac996c72b30eac2f28399ac8c6eda840a6fe8762fc1b84b30d5a2d.svg#plus-square"></use></svg>
<svg class="s16 caret-down" data-testid="chevron-down-icon"><use xlink:href="/assets/icons-6d7d4be41eac996c72b30eac2f28399ac8c6eda840a6fe8762fc1b84b30d5a2d.svg#chevron-down"></use></svg>
</a><div class="dropdown-menu dropdown-menu-right dropdown-extended-height">
<ul>
<li class="dropdown-bold-header">
This group
</li>
<li><a data-track-experiment="new_repo" data-track-event="click_link_new_project_group" data-track-label="plus_menu_dropdown" href="/projects/new?namespace_id=2">New project</a></li>
<li><a data-track-event="click_link_new_subgroup" data-track-label="plus_menu_dropdown" href="/groups/new?parent_id=2">New subgroup</a></li>
<li><a data-track-event="click_link_new_epic" data-track-label="plus_menu_dropdown" href="/groups/group1/-/epics/new">New epic</a></li>

<li class="divider"></li>
<li class="dropdown-bold-header">
GitLab
</li>
<li><a class="qa-global-new-project-link" data-track-experiment="new_repo" data-track-event="click_link_new_project" data-track-label="plus_menu_dropdown" href="/projects/new">New project</a></li>
<li><a data-track-event="click_link_new_group" data-track-label="plus_menu_dropdown" href="/groups/new">New group</a></li>
<li><a class="qa-global-new-snippet-link" data-track-event="click_link_new_snippet_parent" data-track-label="plus_menu_dropdown" href="/-/snippets/new">New snippet</a></li>
</ul>
</div>
</li>
        EOF

        expect(clean_str(rendered)).to eql(clean_str(snapshot))
      end
    end

    context 'with experiment true' do
      before do
        allow(Gitlab::Experimentation).to receive(:active?).and_return(true)
        allow(view).to receive(:experiment_enabled?).and_return(true)
      end

      it 'matches snapshot with project' do
        assign(:project, project)

        render

        snapshot = <<-EOF
<li class="header-new dropdown" data-track-event="click_dropdown" data-track-experiment="new_repo" data-track-label="new_dropdown">
<a class="header-new-dropdown-toggle has-tooltip qa-new-menu-toggle" id="js-onboarding-new-project-link" title="New..." ref="tooltip" aria-label="New..." data-toggle="dropdown" data-placement="bottom" data-container="body" data-display="static" href="/projects/new"><svg class="s16" data-testid="plus-square-icon"><use xlink:href="/assets/icons-6d7d4be41eac996c72b30eac2f28399ac8c6eda840a6fe8762fc1b84b30d5a2d.svg#plus-square"></use></svg>
<svg class="s16 caret-down" data-testid="chevron-down-icon"><use xlink:href="/assets/icons-6d7d4be41eac996c72b30eac2f28399ac8c6eda840a6fe8762fc1b84b30d5a2d.svg#chevron-down"></use></svg>
</a><div class="dropdown-menu dropdown-menu-right dropdown-extended-height">
<ul>
<li class="dropdown-bold-header">
This project
</li>
<li><a data-track-event="click_link_new_issue" data-track-label="plus_menu_dropdown" href="/namespace1/project1/-/issues/new">New issue</a></li>
<li><a data-track-event="click_link_new_mr" data-track-label="plus_menu_dropdown" href="/namespace1/project1/-/merge_requests/new">New merge request</a></li>
<li><a data-track-event="click_link_new_snippet_project" data-track-label="plus_menu_dropdown" href="/namespace1/project1/-/snippets/new">New snippet</a></li>
<li><a data-track-event="click_link" data-track-label="tracking_label" data-track-property="tracking_category_and_group_invite_members_new_dropdown" href="/namespace1/project1/-/project_members">Invite members <gl-emoji title="handshake" data-name="handshake" data-unicode-version="9.0" aria-hidden="true" class="gl-font-base gl-vertical-align-baseline">🤝</gl-emoji></a></li>

<li class="divider"></li>
<li class="dropdown-bold-header">
GitLab
</li>
<li><a class="qa-global-new-project-link" data-track-experiment="new_repo" data-track-event="click_link_new_project" data-track-label="plus_menu_dropdown" href="/projects/new">New project</a></li>
<li><a data-track-event="click_link_new_group" data-track-label="plus_menu_dropdown" href="/groups/new">New group</a></li>
<li><a class="qa-global-new-snippet-link" data-track-event="click_link_new_snippet_parent" data-track-label="plus_menu_dropdown" href="/-/snippets/new">New snippet</a></li>
</ul>
</div>
</li>
        EOF

        expect(clean_str(rendered)).to eql(clean_str(snapshot))
      end

      it 'matches snapshot with group' do
        assign(:group, group)

        render

        snapshot = <<-EOF
<li class="header-new dropdown" data-track-event="click_dropdown" data-track-experiment="new_repo" data-track-label="new_dropdown">
<a class="header-new-dropdown-toggle has-tooltip qa-new-menu-toggle" id="js-onboarding-new-project-link" title="New..." ref="tooltip" aria-label="New..." data-toggle="dropdown" data-placement="bottom" data-container="body" data-display="static" href="/projects/new"><svg class="s16" data-testid="plus-square-icon"><use xlink:href="/assets/icons-6d7d4be41eac996c72b30eac2f28399ac8c6eda840a6fe8762fc1b84b30d5a2d.svg#plus-square"></use></svg>
<svg class="s16 caret-down" data-testid="chevron-down-icon"><use xlink:href="/assets/icons-6d7d4be41eac996c72b30eac2f28399ac8c6eda840a6fe8762fc1b84b30d5a2d.svg#chevron-down"></use></svg>
</a><div class="dropdown-menu dropdown-menu-right dropdown-extended-height">
<ul>
<li class="dropdown-bold-header">
This group
</li>
<li><a data-track-experiment="new_repo" data-track-event="click_link_new_project_group" data-track-label="plus_menu_dropdown" href="/projects/new?namespace_id=2">New project</a></li>
<li><a data-track-event="click_link_new_subgroup" data-track-label="plus_menu_dropdown" href="/groups/new?parent_id=2">New subgroup</a></li>
<li><a data-track-event="click_link_new_epic" data-track-label="plus_menu_dropdown" href="/groups/group1/-/epics/new">New epic</a></li>

<li><a data-track-event="click_link" data-track-label="tracking_label" data-track-property="tracking_category_and_group_invite_members_new_dropdown" href="/groups/group1/-/group_members">Invite members <gl-emoji title="handshake" data-name="handshake" data-unicode-version="9.0" aria-hidden="true" class="gl-font-base gl-vertical-align-baseline">🤝</gl-emoji></a></li>

<li class="divider"></li>
<li class="dropdown-bold-header">
GitLab
</li>
<li><a class="qa-global-new-project-link" data-track-experiment="new_repo" data-track-event="click_link_new_project" data-track-label="plus_menu_dropdown" href="/projects/new">New project</a></li>
<li><a data-track-event="click_link_new_group" data-track-label="plus_menu_dropdown" href="/groups/new">New group</a></li>
<li><a class="qa-global-new-snippet-link" data-track-event="click_link_new_snippet_parent" data-track-label="plus_menu_dropdown" href="/-/snippets/new">New snippet</a></li>
</ul>
</div>
</li>
        EOF

        expect(clean_str(rendered)).to eql(clean_str(snapshot))
      end
    end
  end
end
