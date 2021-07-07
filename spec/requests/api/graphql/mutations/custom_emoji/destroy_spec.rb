# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Deletion of custom emoji' do
  include GraphqlHelpers

  let_it_be(:group) { create(:group) }
  let_it_be(:current_user) { create(:user) }
  let_it_be_with_reload(:custom_emoji) { create(:custom_emoji, group: group) }

  let(:mutation) do
    variables = {
      id: GitlabSchema.id_from_object(custom_emoji).to_s
    }

    graphql_mutation(:destroy_custom_emoji, variables)
  end

  context 'when the user has no permissions' do
    it 'does not delete custom emoji' do
      expect { post_graphql_mutation(mutation, current_user: current_user) }.not_to change(CustomEmoji, :count)
    end
  end

  context 'when user has permission' do
    before do
      group.add_developer(current_user)
    end

    it 'deletes custom emoji' do
      expect { post_graphql_mutation(mutation, current_user: current_user) }.to change(CustomEmoji, :count).by(-1)
    end
  end
end
