# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SearchHelper do
  describe '#search_filter_input_options' do
    let(:options) { helper.search_filter_input_options(:issues) }

    context 'with multiple issue assignees feature' do
      before do
        stub_licensed_features(multiple_issue_assignees: true)
      end

      it 'allows multiple assignees in project context' do
        @project = create :project

        expect(options[:data][:'multiple-assignees']).to eq('true')
      end

      it 'allows multiple assignees in group context' do
        @group = create :group

        expect(options[:data][:'multiple-assignees']).to eq('true')
      end

      it 'allows multiple assignees in dashboard context' do
        expect(options[:data][:'multiple-assignees']).to eq('true')
      end
    end

    context 'without multiple issue assignees feature' do
      before do
        stub_licensed_features(multiple_issue_assignees: false)
      end

      it 'does not allow multiple assignees in project context' do
        @project = create :project

        expect(options[:data][:'multiple-assignees']).to be(nil)
      end

      it 'does not allow multiple assignees in group context' do
        @group = create :group

        expect(options[:data][:'multiple-assignees']).to be(nil)
      end

      it 'allows multiple assignees in dashboard context' do
        expect(options[:data][:'multiple-assignees']).to eq('true')
      end
    end
  end

  describe 'search_autocomplete_opts' do
    context "with a user" do
      let(:user) { create(:user) }

      before do
        allow(self).to receive(:current_user).and_return(user)
      end

      it 'includes the users recently viewed epics' do
        recent_epics = instance_double(::Gitlab::Search::RecentEpics)
        expect(::Gitlab::Search::RecentEpics).to receive(:new).with(user: user).and_return(recent_epics)
        group1 = create(:group, :public, :with_avatar)
        group2 = create(:group, :public)
        epic1 = create(:epic, title: 'epic 1', group: group1)
        epic2 = create(:epic, title: 'epic 2', group: group2)

        expect(recent_epics).to receive(:search).with('the search term').and_return(Epic.id_in_ordered([epic1.id, epic2.id]))

        results = search_autocomplete_opts("the search term")

        expect(results.count).to eq(2)

        expect(results[0]).to include({
          category: 'Recent epics',
          id: epic1.id,
          label: 'epic 1',
          url: Gitlab::Routing.url_helpers.group_epic_path(epic1.group, epic1),
          avatar_url: group1.avatar_url
        })

        expect(results[1]).to include({
          category: 'Recent epics',
          id: epic2.id,
          label: 'epic 2',
          url: Gitlab::Routing.url_helpers.group_epic_path(epic2.group, epic2),
          avatar_url: '' # This group didn't have an avatar so set this to ''
        })
      end
    end
  end

  describe '#search_entries_info_template' do
    let(:com_value) { true }
    let(:elasticsearch_enabled) { true }
    let(:show_snippets) { true }
    let(:collection) { Kaminari.paginate_array([:foo]).page(1).per(10) }
    let(:user) { create(:user) }
    let(:message) { "Showing %{count} %{scope} for%{term_element}" }
    let(:new_message) { message + " in your personal and project snippets" }

    subject { search_entries_info_template(collection) }

    before do
      @show_snippets = show_snippets
      @current_user = user

      allow(Gitlab).to receive(:com?).and_return(com_value)
      stub_ee_application_setting(search_using_elasticsearch: elasticsearch_enabled)
    end

    shared_examples 'returns old message' do
      it do
        expect(subject).to eq message
      end
    end

    context 'when all requirements are met' do
      it 'returns a custom message' do
        expect(subject).to eq new_message
      end
    end

    context 'when not in Gitlab.com' do
      let(:com_value) { false }

      it_behaves_like 'returns old message'
    end

    context 'when elastic search is not enabled' do
      let(:elasticsearch_enabled) { false }

      it_behaves_like 'returns old message'
    end

    context 'when no user is present' do
      let(:user) { nil }

      it_behaves_like 'returns old message'
    end

    context 'when not searching for snippets' do
      let(:show_snippets) { nil }

      it_behaves_like 'returns old message'
    end
  end

  describe '#highlight_and_truncate_issue' do
    let(:description) { 'hello world' }
    let(:issue) { create(:issue, description: description) }
    let(:user) { create(:user) }
    let(:search_highlight) { {} }

    before do
      allow(self).to receive(:current_user).and_return(user)
      stub_ee_application_setting(search_using_elasticsearch: true)
    end

    # Elasticsearch returns Elasticsearch::Model::HashWrapper class for the highlighting
    subject { highlight_and_truncate_issue(issue, 'test', Elasticsearch::Model::HashWrapper.new(search_highlight)) }

    context 'when description is not present' do
      let(:description) { nil }

      it 'does nothing' do
        expect(self).not_to receive(:sanitize)

        subject
      end
    end

    context 'when description present' do
      using RSpec::Parameterized::TableSyntax

      where(:description, :search_highlight, :expected) do
        'test'                                                                 | { 1 => { description: ['gitlabelasticsearch→test←gitlabelasticsearch'] } } | "<span class='gl-text-black-normal gl-font-weight-bold'>test</span>"
        '<span style="color: blue;">this test should not be blue</span>'       | { 1 => { description: ['<span style="color: blue;">this gitlabelasticsearch→test←gitlabelasticsearch should not be blue</span>'] } } | "<span>this <span class='gl-text-black-normal gl-font-weight-bold'>test</span> should not be blue</span>"
        '<a href="#" onclick="alert(\'XSS\')">Click Me test</a>'               | { 1 => { description: ['<a href="#" onclick="alert(\'XSS\')">Click Me gitlabelasticsearch→test←gitlabelasticsearch</a>'] } } | "<a href='#'>Click Me <span class='gl-text-black-normal gl-font-weight-bold'>test</span></a>"
        '<script type="text/javascript">alert(\'Another XSS\');</script> test' | { 1 => { description: ['<script type="text/javascript">alert(\'Another XSS\');</script> gitlabelasticsearch→test←gitlabelasticsearch'] } } | "alert(&apos;Another XSS&apos;); <span class='gl-text-black-normal gl-font-weight-bold'>test</span>"
        'Lorem test ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec.' | { 1 => { description: ['Lorem gitlabelasticsearch→test←gitlabelasticsearch ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec.'] } } | "Lorem <span class='gl-text-black-normal gl-font-weight-bold'>test</span> ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Don..."
      end

      with_them do
        before do
          # table syntax doesn't allow use of calculated fields so we must fake issue.id
          # to ensure the test goes down the correct path
          allow(issue).to receive(:id).and_return(1)
        end

        it 'sanitizes, truncates, and highlights the search term' do
          expect(subject).to eq(expected)
        end
      end
    end
  end
end
