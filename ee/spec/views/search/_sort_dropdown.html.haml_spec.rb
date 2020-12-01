# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'search/_sort_dropdown' do
  context 'when the search page is opened' do
    before do
      @scope = 'issues'
    end

    context 'with advanced search' do
      before do
        @search_service = instance_double(SearchService, use_elasticsearch?: true)
      end

      it 'displays the correct sort elements' do
        render

        expect(rendered).to have_selector('a', text: 'Relevant')
        expect(rendered).to have_selector('a', text: 'Last created')
      end
    end

    context 'without advanced search' do
      before do
        @search_service = instance_double(SearchService, use_elasticsearch?: false)
      end

      it 'displays the correct sort elements' do
        render

        expect(rendered).not_to have_selector('a', text: 'Relevant')
        expect(rendered).to have_selector('a', text: 'Last created')
      end
    end
  end
end
