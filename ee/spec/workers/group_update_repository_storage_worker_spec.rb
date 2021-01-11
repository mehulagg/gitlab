# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GroupUpdateRepositoryStorageWorker do
  subject { described_class.new }

  it_behaves_like 'an update storage move worker' do
    let_it_be_with_refind(:container) { create(:group, :wiki_repo) }
    let_it_be(:repository_storage_move) { create(:group_repository_storage_move) }

    let(:service_klass) { Groups::UpdateRepositoryStorageService }
    let(:repository_storage_move_klass) { GroupRepositoryStorageMove }
  end
end
