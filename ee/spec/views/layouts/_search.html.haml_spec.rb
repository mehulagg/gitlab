# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'layouts/_search' do
  let(:group) { create(:group) }
  let(:project) { nil }
  let(:scope) { 'epics' }
  let(:search_context) do
    instance_double(Gitlab::SearchContext,
      project: project,
      group: group,
      scope: scope,
      ref: nil,
      snippets: [],
      search_url: '/search',
      project_metadata: {},
      group_metadata: {})
  end

  before do
    allow(view).to receive(:search_context).and_return(search_context)
    allow(search_context).to receive(:code_search?).and_return(false)
    allow(search_context).to receive(:for_snippets?).and_return(false)
    allow(search_context).to receive(:for_project?).and_return(false)
    allow(search_context).to receive(:for_group?).and_return(true)
  end

  context 'when doing group level search' do
    context 'when on epics' do
      it 'sets scope to epics' do
        render

        expect(rendered).to have_css("input[name='scope'][value='epics']", count: 1, visible: false)
      end
    end
  end
end
