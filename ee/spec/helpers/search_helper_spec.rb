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

  describe '#project_autocomplete' do
    let(:user) { create(:user) }

    before do
      @project = create(:project, :repository)
      allow(self).to receive(:current_user).and_return(user)
    end

    context 'with a licensed user' do
      it "does include feature flags" do
        expect(project_autocomplete.find { |i| i[:label] == 'Feature Flags' }).to be_present
      end
    end
  end

  describe '#search_entries_info_template' do
    let(:com_value) { true }
    let(:flag_enabled) { true }
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
      stub_feature_flags(restricted_snippet_scope_search: flag_enabled)
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

    context 'when flag restricted_snippet_scope_search is not enabled' do
      let(:flag_enabled) { false }

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

  describe '#show_switch_to_basic_search?' do
    let(:use_elasticsearch) { true }
    let(:scope) { 'commits' }
    let(:search_service) { instance_double(Search::GlobalService, use_elasticsearch?: use_elasticsearch, scope: scope) }

    subject { show_switch_to_basic_search?(search_service) }

    before do
      stub_feature_flags(switch_to_basic_search: true)
    end

    context 'when :switch_to_basic_search feature is disabled' do
      before do
        stub_feature_flags(switch_to_basic_search: false)
      end

      it { is_expected.to eq(false) }
    end

    context 'when not currently using elasticsearch' do
      let(:use_elasticsearch) { false }

      it { is_expected.to eq(false) }
    end

    context 'when project scope' do
      before do
        @project = create(:project)
      end

      it { is_expected.to eq(true) }
    end

    context 'when commits tab' do
      it { is_expected.to eq(false) }
    end

    context 'when issues tab' do
      let(:scope) { 'issues' }

      it { is_expected.to eq(true) }
    end
  end
end
