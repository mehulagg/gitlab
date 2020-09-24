# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Group elastic search', :js, :elastic, :sidekiq_might_not_need_inline do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:project) { create(:project, :repository, :wiki_repo, namespace: group) }

  def choose_group(group)
    find('.js-search-group-dropdown').click
    wait_for_requests

    page.within '.js-search-form' do
      click_link group.name
    end
  end

  before do
    stub_ee_application_setting(elasticsearch_search: true, elasticsearch_indexing: true)

    project.add_maintainer(user)
    group.add_owner(user)

    sign_in(user)

    visit(search_path)
    choose_group(group)
  end

  describe 'issue search' do
    before do
      create(:issue, project: project, title: 'chosen issue title')

      ensure_elasticsearch_index!
    end

    it 'finds the issue' do
      submit_search('chosen')
      select_search_scope('Issues')

      expect(page).to have_content('chosen issue title')
    end
  end

  describe 'blob search' do
    before do
      project.repository.index_commits_and_blobs

      ensure_elasticsearch_index!
    end

    it 'finds files' do
      submit_search('def')
      select_search_scope('Code')

      expect(page).to have_selector('.file-content .code')
    end
  end

  describe 'wiki search' do
    let(:wiki) { ProjectWiki.new(project, user) }

    before do
      wiki.create_page('test.md', '# term')
      wiki.index_wiki_blobs

      ensure_elasticsearch_index!
    end

    it 'finds pages' do
      submit_search('term')
      select_search_scope('Wiki')

      expect(page).to have_selector('.file-content .code')
      expect(page).to have_selector('span.line[lang="markdown"]')
    end
  end

  describe 'commit search' do
    before do
      project.repository.index_commits_and_blobs
      ensure_elasticsearch_index!
    end

    it 'finds commits' do
      submit_search('add')
      select_search_scope('Commits')

      expect(page).to have_selector('.commit-list > .commit')
    end
  end
end

RSpec.describe 'Group elastic search redactions', :elastic do
  it_behaves_like 'a redacted search results page' do
    let(:search_path) { group_path(public_group) }
  end
end
