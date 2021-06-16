# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::MergeRequests, '(JavaScript fixtures)', type: :request do
  include ApiHelpers
  include WikiHelpers
  include JavaScriptFixturesHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group, :wiki_repo) }
  let_it_be(:project) { create(:project, :wiki_repo, namespace: user.namespace, creator: user) }
  let_it_be(:group_wiki_page) { create(:wiki_page, wiki: group.wiki) }
  let_it_be(:project_wiki_page) { create(:wiki_page, wiki: project.wiki) }

  fixture_subdir = 'api/markdown'

  before(:all) do
    clean_frontend_fixtures(fixture_subdir)

    stub_group_wikis(true)
    wiki.container.add_owner(user)
    group.add_owner(user)
  end

  markdown_examples = begin
    yaml_file_path = File.expand_path('api_markdown.yml', __dir__)
    yaml = File.read(yaml_file_path)
    YAML.safe_load(yaml, symbolize_names: true)
  end

  markdown_examples.each do |markdown_example|
    name = markdown_example.fetch(:name)
    context = markdown_example.fetch(:context) || ''
    api_url = case context
              when 'project'
                "/#{project.web_url}/preview_markdown"
              when 'group'
                "/#{group.web_url}/preview_markdown"
              when 'project_wiki'
                "/#{project.web_url}/-/wikis/#{project_wiki_page.path}/preview_markdown"
              when 'group_wiki'
                "/#{group.web_url}/-/wikis/#{group_wiki_page.path}/preview_markdown"
              else
                "/markdown"
              end

    context "for #{name}" do
      let(:markdown) { markdown_example.fetch(:markdown) }

      name = "#{context}_#{name}" if !context.empty?

      it "#{fixture_subdir}/#{name}.json" do
        post api(api_url), params: { text: markdown, gfm: true }
        expect(response).to be_successful
      end
    end
  end
end
