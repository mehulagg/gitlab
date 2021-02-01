# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Packages::Composer::CacheCleanupWorker, type: :worker do
  describe '#perform' do
    let_it_be(:group) { create(:group) }

    let!(:page1) { create(:composer_cache_file, delete_at: nil, group: group, file_sha256: '124') }
    let!(:page2) { create(:composer_cache_file, delete_at: 2.days.from_now, group: group, file_sha256: '3456') }
    let!(:page3) { create(:composer_cache_file, delete_at: DateTime.now, group: group, file_sha256: '5346') }
    let!(:page4) { create(:composer_cache_file, delete_at: nil, group: group, file_sha256: '56889') }

    subject { described_class.new.perform }

    before do
      # emulate group deletion
      page4.update_columns(namespace_id: nil)
    end

    it 'deletes expired packages' do
      expect { subject }.to change { Packages::Composer::CacheFile.count }.by(-2)
      expect { page1.reload }.not_to raise_error ActiveRecord::RecordNotFound
      expect { page2.reload }.not_to raise_error ActiveRecord::RecordNotFound
      expect { page3.reload }.to raise_error ActiveRecord::RecordNotFound
      expect { page4.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
