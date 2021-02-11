# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EpicsHelper, type: :helper do
  include ApplicationHelper

  describe '#epic_new_app_data' do
    let(:group) { create(:group) }

    it 'returns the correct data for a new epic' do
      expected_data = {
        group_path: group.full_path,
        group_epics_path: "/groups/#{group.full_path}/-/epics",
        labels_fetch_path: "/groups/#{group.full_path}/-/labels.json?include_ancestor_groups=true&only_group_labels=true",
        labels_manage_path: "/groups/#{group.full_path}/-/labels",
        markdown_preview_path: "/groups/#{group.full_path}/preview_markdown",
        markdown_docs_path: help_page_path('user/markdown')
      }

      expect(helper.epic_new_app_data(group)).to match(hash_including(expected_data))
    end
  end

  describe '#epic_endpoint_query_params' do
    let(:endpoint_data) do
      {
        only_group_labels: true,
        include_ancestor_groups: true,
        include_descendant_groups: true
      }
    end

    it 'includes Epic specific options in JSON format' do
      opts = epic_endpoint_query_params({})

      expect(opts[:data][:endpoint_query_params]).to eq(endpoint_data.to_json)
    end

    it 'includes data provided in param' do
      opts = epic_endpoint_query_params(data: { default_param: true })

      expect(opts[:data]).to eq({ default_param: true }.merge(endpoint_query_params: endpoint_data.to_json))
    end
  end

  describe '#epic_state_dropdown_link' do
    it 'returns the active link when selected state is same as the link' do
      expect(helper.epic_state_dropdown_link(:opened, :opened))
        .to eq('<a class="is-active" href="?state=opened">Open epics</a>')
    end

    it 'returns the non-active link when selected state is different from the link' do
      expect(helper.epic_state_dropdown_link(:opened, :closed))
        .to eq('<a class="" href="?state=opened">Open epics</a>')
    end
  end

  describe '#epic_state_title' do
    it 'returns "Open" when the state is opened' do
      expect(epic_state_title(:opened)).to eq('Open epics')
    end

    it 'returns humanized string when the state is other than opened' do
      expect(epic_state_title(:some_other_state)).to eq('Some other state epics')
    end
  end

  describe '#epic_timeframe' do
    let(:epic) { build(:epic, start_date: start_date, end_date: end_date) }

    subject { epic_timeframe(epic) }

    context 'when both dates are from the same year' do
      let(:start_date) { Date.new(2018, 7, 22) }
      let(:end_date) { Date.new(2018, 8, 15) }

      it 'returns start date with year omitted and end date with year' do
        is_expected.to eq('Jul 22 – Aug 15, 2018')
      end
    end

    context 'when both dates are from different years' do
      let(:start_date) { Date.new(2018, 7, 22) }
      let(:end_date) { Date.new(2019, 7, 22) }

      it 'returns start date with year omitted and end date with year' do
        is_expected.to eq('Jul 22, 2018 – Jul 22, 2019')
      end
    end

    context 'when only start date is present' do
      let(:start_date) { Date.new(2018, 7, 22) }
      let(:end_date) { nil }

      it 'returns start date with year' do
        is_expected.to eq('Jul 22, 2018 – No end date')
      end
    end

    context 'when only end date is present' do
      let(:start_date) { nil }
      let(:end_date) { Date.new(2018, 7, 22) }

      it 'returns end date with year' do
        is_expected.to eq('No start date – Jul 22, 2018')
      end
    end
  end

  describe 'Issue Flowchart' do
    let_it_be_with_reload(:epic) { create(:epic) }
    let_it_be(:project) { create(:project, group: epic.group) }

    subject { helper.linked_issue_flowchart(epic) }

    before do
      project.add_reporter(epic.author)
      allow(helper).to receive(:current_user).and_return(epic.author)
    end

    context 'without blocking issues' do
      it { is_expected.to be_nil }
    end

    context 'with blocking issues' do
      let_it_be_with_reload(:blocking_issue) { create(:issue, project: project) }
      let_it_be(:blocked_issue) { create(:issue, project: project) }
      let_it_be(:unblocked_issue) { create(:issue, project: project) }
      let_it_be(:non_permissioned_issue) { create(:issue) }

      # Flowchart excludes any issues or links which are not in the epic
      let_it_be(:other_epic) { create(:epic, group: epic.group) }
      let_it_be(:other_epic_issue) { create(:issue, project: project) }
      let_it_be(:other_epic_blocking_issue) { create(:issue, project: project) }
      let_it_be(:other_epic_blocked_issue) { create(:issue, project: project) }

      # source blocks target
      let_it_be(:issue_link) { create(:issue_link, source: blocking_issue, target: blocked_issue) }
      let_it_be(:other_epic_blocking_issue_link) { create(:issue_link, source: other_epic_blocking_issue, target: blocked_issue) }
      let_it_be(:other_epic_blocked_link) { create(:issue_link, source: blocking_issue, target: other_epic_blocked_issue) }

      before do
        [blocking_issue, blocked_issue, unblocked_issue, non_permissioned_issue].each do |issue|
          create(:epic_issue, issue: issue, epic: epic)
        end

        [other_epic_issue, other_epic_blocked_issue, other_epic_blocking_issue].each do |issue|
          create(:epic_issue, issue: issue, epic: other_epic)
        end
      end

      it 'represents the dependencies within the epic in a mermaid flowchart' do
        expect(subject).to eq(
          <<~MARKDOWN.chomp
          ```mermaid
          graph LR

          3("3: #{unblocked_issue.title}")
          click 3 href "http://test.host/group6/project1/-/issues/3" "#{unblocked_issue.title}"
          2("2: #{blocked_issue.title}")
          click 2 href "http://test.host/group6/project1/-/issues/2" "#{blocked_issue.title}"
          1("1: #{blocking_issue.title}")
          click 1 href "http://test.host/group6/project1/-/issues/1" "#{blocking_issue.title}"

          1-->2
          ```
          MARKDOWN
        )
      end

      context 'with double-quotes in an issue title' do
        before do
          blocking_issue.update!(title: 'My "Odd" title')
        end

        it { is_expected.to include('My #quot;Odd#quot; title') }
      end

      context 'with special characters in an issue title' do
        before do
          blocking_issue.update!(title: 'My <p>Odd</p> title')
        end

        it { is_expected.to include("\"#{blocking_issue.id}: My <p>Odd</p> title\"") }
      end

      context 'with very long issue titles' do
        before do
          blocking_issue.update!(title: 'This is a very long title which I expect to be cutoff because mermaid does not do well with long strings in nodes')
        end

        it { is_expected.to include('This is a very long title which I exp...') }
      end
    end
  end
end
