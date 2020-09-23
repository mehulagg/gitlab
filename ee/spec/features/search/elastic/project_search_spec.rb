# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Project elastic search', :js, :elastic do
  let(:user) { create(:user) }
  let(:project) { create(:project, :repository, :wiki_repo, namespace: user.namespace) }

  before do
    stub_ee_application_setting(elasticsearch_search: true, elasticsearch_indexing: true)

    project.add_maintainer(user)
    sign_in(user)

    visit project_path(project)
  end

  describe 'searching' do
    it 'finds issues', :sidekiq_inline do
      create(:issue, project: project, title: 'Test searching for an issue')
      ensure_elasticsearch_index!

      submit_search('Test')
      select_search_scope('Issues')

      expect(page).to have_selector('.results', text: 'Test searching for an issue')
    end

    it 'finds merge requests', :sidekiq_inline do
      create(:merge_request, source_project: project, target_project: project, title: 'Test searching for an MR')
      ensure_elasticsearch_index!

      submit_search('Test')
      select_search_scope('Merge requests')

      expect(page).to have_selector('.results', text: 'Test searching for an MR')
    end

    it 'finds milestones', :sidekiq_inline do
      create(:milestone, project: project, title: 'Test searching for a milestone')
      ensure_elasticsearch_index!

      submit_search('Test')
      select_search_scope('Milestones')

      expect(page).to have_selector('.results', text: 'Test searching for a milestone')
    end

    it 'finds wiki pages', :sidekiq_inline do
      project.wiki.create_page('test.md', 'Test searching for a wiki page')
      project.wiki.index_wiki_blobs

      submit_search('Test')
      select_search_scope('Wiki')

      expect(page).to have_selector('.results', text: 'Test searching for a wiki page')
    end

    it 'finds notes', :sidekiq_inline do
      create(:note, project: project, note: 'Test searching for a comment')
      ensure_elasticsearch_index!

      submit_search('Test')
      select_search_scope('Comments')

      expect(page).to have_selector('.results', text: 'Test searching for a comment')
    end

    it 'finds commits', :sidekiq_inline do
      project.repository.index_commits_and_blobs

      submit_search('initial')
      select_search_scope('Commits')

      expect(page).to have_selector('.results', text: 'Initial commit')
    end

    it 'finds blobs', :sidekiq_inline do
      project.repository.index_commits_and_blobs

      submit_search('def')
      select_search_scope('Code')

      expect(page).to have_selector('.results', text: 'def username_regex')
    end
  end
end

RSpec.describe 'Project elastic search redactions', :elastic do
  it_behaves_like 'a redacted search results page' do
    let(:search_path) { project_path(public_restricted_project) }
  end
end
