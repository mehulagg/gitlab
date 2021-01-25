# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::RepositoryStorageMove, type: :model do
  it_behaves_like 'handles repository moves', check_worker: false do
    let_it_be_with_refind(:container) { create(:group) }

    let(:repository_storage_factory_key) { :group_repository_storage_move }
    let(:error_key) { :group }
  end
end
