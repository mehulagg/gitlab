# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::ImportExport::ExportService do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) do
    create(:group).tap do |g|
      g.add_owner(user)
    end
  end

  let(:shared) { Gitlab::ImportExport::Shared.new(group) }
  let(:archive_path) { shared.archive_path }

  subject(:export_service) { described_class.new(group: group, user: user, params: { shared: shared }) }

  after do
    FileUtils.rm_rf(archive_path)
  end

  describe '#execute' do
    it 'exports the group wiki repository' do
      expect_next_instance_of(::Gitlab::ImportExport::WikiRepoSaver, exportable: group, shared: shared) do |exporter|
        expect(exporter).to receive(:save).and_return(true)
      end

      export_service.execute
    end
  end
end
