# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::ScheduleBulkRepositoryShardMovesService do
  it_behaves_like 'schedules bulk repository shard moves' do
    let_it_be_with_reload(:container) { create(:project, :repository).tap { |project| project.track_project_repository } }

    let(:move_service_klass) { ProjectRepositoryStorageMove }
    let(:bulk_worker_klass) { ::ProjectScheduleBulkRepositoryShardMovesWorker }
  end
end
