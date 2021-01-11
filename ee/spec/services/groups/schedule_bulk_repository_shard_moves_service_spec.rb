# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::ScheduleBulkRepositoryShardMovesService do
  it_behaves_like 'moves repository shard in bulk' do
    let_it_be_with_reload(:container) { create(:group, :wiki_repo) }

    let(:move_service_klass) { GroupRepositoryStorageMove }
    let(:bulk_worker_klass) { ::GroupScheduleBulkRepositoryShardMovesWorker }
  end
end
