# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::Entities::SnippetRepositoryStorageMove do
  describe '#as_json' do
    subject { entity.as_json }

    let(:storage_move) { create(:snippet_repository_storage_move, :scheduled, destination_storage_name: 'test_second_storage') }
    let(:entity) { described_class.new(storage_move) }

    it 'includes basic fields' do
      is_expected.to include(
        state: 'scheduled',
        source_storage_name: 'default',
        destination_storage_name: 'test_second_storage',
        snippet: a_kind_of(Hash)
      )
    end
  end
end
