# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::WikisController do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, namespace: user.namespace) }

  let(:wiki) { Wiki.for_container(project, user) }
  let(:wiki_page) { create(:wiki_page, wiki: wiki, title: 'page title test', content: 'hello world') }

  before do
    project.add_maintainer(user)

    sign_in(user)
  end

  context 'when accept header is */*' do
    it 'returns a 200' do
      headers = { 'Accept': '*/*' }

      get wiki_page_path(wiki, wiki_page, action: :edit), headers: headers

      binding.pry

      expect(response).to have_http_status(200)
    end
  end
end
