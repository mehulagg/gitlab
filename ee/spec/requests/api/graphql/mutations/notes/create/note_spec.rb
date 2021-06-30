# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Adding a Note to an Epic' do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }

  let(:epic) { create(:epic, group: group) }
  let(:mutation) do
    variables = {
      noteable_id: GitlabSchema.id_from_object(epic).to_s,
      body: 'Body text'
    }

    graphql_mutation(:create_note, variables)
  end

  def mutation_response
    graphql_mutation_response(:create_note)
  end

  before do
    stub_licensed_features(epics: true)
  end

  context 'when the user does not have permission' do
    let(:group) { create(:group, :private) }

    it_behaves_like 'a Note mutation when the user does not have permission'
  end

  context 'when the user has permission' do
    let(:group) { create(:group, :public) }

    it_behaves_like 'a Note mutation that creates a Note'
  end
end
