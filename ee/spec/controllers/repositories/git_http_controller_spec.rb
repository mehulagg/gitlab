# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Repositories::GitHttpController do
  include GitHttpHelpers

  describe 'GET #info_refs' do
    let_it_be(:project) { create(:project, :public, :repository) }

    let(:container) { project }
    let(:user) { project.owner }
    let(:repository_path) { "#{container.full_path}.git" }
    let(:params) { { repository_path: repository_path, service: 'git-upload-pack' } }

    before do
      request.headers.merge! auth_env(user.username, user.password, nil)
    end

    it 'calls use_replica_if_possible' do
      session = instance_double(::Gitlab::Database::LoadBalancing::Session)
      allow(::Gitlab::Database::LoadBalancing::Session).to receive(:current).and_return(session)
      allow(session).to receive(:ignore_writes).and_yield

      expect(session).to receive(:use_replica_if_possible!)

      get :info_refs, params: params

      expect(response).to have_gitlab_http_status(:ok)
    end
  end

  context 'when repository container is a group wiki' do
    include WikiHelpers

    let_it_be(:group) { create(:group, :wiki_repo) }
    let_it_be(:user) { create(:user) }

    before_all do
      group.add_owner(user)
    end

    before do
      stub_group_wikis(true)
    end

    it_behaves_like Repositories::GitHttpController do
      let(:container) { group.wiki }
      let(:access_checker_class) { Gitlab::GitAccessWiki }
    end
  end
end
