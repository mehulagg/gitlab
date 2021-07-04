# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::CustomEmoji::Destroy do
  let_it_be(:group) { create(:group) }
  let_it_be(:user) { create(:user) }
  let_it_be_with_reload(:custom_emoji) { create(:custom_emoji, group: group) }

  let(:args) { { id: custom_emoji.to_global_id } }
  let(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }

  context 'field tests' do
    subject { described_class }

    it { is_expected.to have_graphql_arguments(:id) }
    it { is_expected.to have_graphql_field(:custom_emoji) }
  end

  describe '#resolve' do
    subject { mutation.resolve(**args) }

    it 'returns unauthorized if user has no permissions' do
      expect { subject }
        .to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
    end

    context 'when user has permission to destroy custom emoji' do
      before do
        group.add_developer(user)
      end

      it 'deletes custom emoji' do
        result = subject

        expect(result[:custom_emoji][:name]).to eq(custom_emoji.name)
      end
    end
  end
end
