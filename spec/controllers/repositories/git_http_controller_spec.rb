# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Repositories::GitHttpController do
  let_it_be(:project) { create(:project, :public, :repository) }
  let_it_be(:personal_snippet) { create(:personal_snippet, :public, :repository) }
  let_it_be(:project_snippet) { create(:project_snippet, :public, :repository, project: project) }

  context 'when repository container is a project' do
    it_behaves_like Repositories::GitHttpController do
      let(:container) { project }
      let(:user) { project.owner }
      let(:access_checker_class) { Gitlab::GitAccess }
    end
  end

  context 'when repository container is a project wiki' do
    it_behaves_like Repositories::GitHttpController do
      let(:container) { create(:project_wiki, :empty_repo, project: project) }
      let(:user) { project.owner }
      let(:access_checker_class) { Gitlab::GitAccessWiki }
    end
  end

  context 'when repository container is a personal snippet' do
    it_behaves_like Repositories::GitHttpController do
      let(:container) { personal_snippet }
      let(:user) { personal_snippet.author }
      let(:access_checker_class) { Gitlab::GitAccessSnippet }
      let(:repository_path) { "snippets/#{personal_snippet.to_param}.git" }
    end
  end

  context 'when repository container is a project snippet' do
    it_behaves_like Repositories::GitHttpController do
      let(:container) { project_snippet }
      let(:user) { project_snippet.author }
      let(:access_checker_class) { Gitlab::GitAccessSnippet }
      let(:repository_path) { "#{project.full_path}/snippets/#{project_snippet.to_param}.git" }
    end
  end
end
