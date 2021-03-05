# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::MergeRequests, '(JavaScript fixtures)', type: :request do
  include ApiHelpers
  include JavaScriptFixturesHelpers

  let_it_be(:admin) { create(:admin, name: 'root') }
  let_it_be(:namespace) { create(:namespace, name: 'gitlab-test' )}

  before(:all) do
    clean_frontend_fixtures('api/markdown')
  end

  it 'api/markdown/bold.json' do
    post api("/markdown"), params: { text: '**bold**' }

    expect(response).to be_successful
  end
end
