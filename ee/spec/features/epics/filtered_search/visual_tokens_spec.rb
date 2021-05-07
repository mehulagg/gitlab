# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'epics list', :js do
  include FilteredSearchHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, :public) }
  let_it_be(:label) { create(:group_label, group: group, title: 'bug') }
  let_it_be(:epic) { create(:epic, group: group, start_date: 10.days.ago, due_date: 5.days.ago) }

  let(:filtered_search) { find('.filtered-search') }
  let(:filter_author_dropdown) { find("#js-dropdown-author .filter-dropdown") }
  let(:filter_label_dropdown) { find("#js-dropdown-label .filter-dropdown") }
  let(:js_dropdown_my_reaction) { '#js-dropdown-my-reaction' }
  let(:filter_emoji_dropdown) { find("#js-dropdown-my-reaction .filter-dropdown") }

  let_it_be(:award_emoji_star) { create(:award_emoji, name: 'star', user: user, awardable: epic) }

  before do
    stub_licensed_features(epics: true)
    stub_feature_flags(vue_epics_list: false)

    sign_in(user)

    visit group_epics_path(group)
  end

  context 'editing author token' do
    before do
      input_filtered_search('author:=@root', submit: false)
      first('.tokens-container .filtered-search-token').click
    end

    it 'converts keyword into visual token' do
      page.within('.tokens-container') do
        expect(page).to have_selector('.js-visual-token')
        expect(page).to have_content('Author')
      end
    end

    it 'opens author dropdown' do
      expect(page).to have_css('#js-dropdown-author', visible: true)
    end

    it 'makes value editable' do
      expect_filtered_search_input('@root')
    end

    it 'filters value' do
      filtered_search.send_keys(:backspace)

      expect(page).to have_css('#js-dropdown-author .filter-dropdown .filter-dropdown-item', count: 1)
    end
  end

  context 'editing label token' do
    before do
      input_filtered_search("label:=~#{label.title}", submit: false)
      first('.tokens-container .filtered-search-token').click
    end

    it 'converts keyword into visual token' do
      page.within('.tokens-container') do
        expect(page).to have_selector('.js-visual-token')
        expect(page).to have_content('Label')
      end
    end

    it 'opens label dropdown' do
      expect(filter_label_dropdown.find('.filter-dropdown-item', text: label.title)).to be_visible
      expect(page).to have_css('#js-dropdown-label', visible: true)
    end

    it 'makes value editable' do
      expect_filtered_search_input("~#{label.title}")
    end

    it 'filters value' do
      expect(filter_label_dropdown.find('.filter-dropdown-item', text: label.title)).to be_visible

      filtered_search.send_keys(:backspace)

      filter_label_dropdown.find('.filter-dropdown-item')

      expect(page.all('#js-dropdown-label .filter-dropdown .filter-dropdown-item').size).to eq(1)
    end
  end

  context 'editing reaction emoji token' do
    before_all do
      create_list(:award_emoji, 2, user: user, name: 'thumbsup')
      create_list(:award_emoji, 1, user: user, name: 'thumbsdown')
      create_list(:award_emoji, 3, user: user, name: 'star')
    end

    context 'when user is not logged in' do
      it 'does not open when the search bar has my-reaction=' do
        filtered_search.set('my-reaction=')

        expect(page).not_to have_css(js_dropdown_my_reaction)
      end
    end

    context 'when user is logged in' do
      before_all do
        group.add_maintainer(user)
      end

      it 'opens when the search bar has my-reaction=' do
        filtered_search.set('my-reaction:=')

        expect(page).to have_css(js_dropdown_my_reaction, visible: true)
      end

      it 'loads all the emojis when opened' do
        input_filtered_search('my-reaction:=', submit: false, extra_space: false)

        expect_filtered_search_dropdown_results(filter_emoji_dropdown, 3)
      end

      it 'shows the most populated emoji at top of dropdown' do
        input_filtered_search('my-reaction:=', submit: false, extra_space: false)

        expect(first("#{js_dropdown_my_reaction} .filter-dropdown li")).to have_content(award_emoji_star.name)
      end
    end
  end
end
