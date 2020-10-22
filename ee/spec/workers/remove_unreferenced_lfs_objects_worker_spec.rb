# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RemoveUnreferencedLfsObjectsWorker do
  include EE::GeoHelpers

  describe '#perform' do
    context 'when running in a Geo primary node' do
      let_it_be(:primary) { create(:geo_node, :primary) }
      let_it_be(:secondary) { create(:geo_node) }

      it 'logs an event to the Geo event log for every unreferenced LFS objects' do
        stub_current_geo_node(primary)
        unreferenced_lfs_object_1 = create(:lfs_object, :with_file)
        unreferenced_lfs_object_2 = create(:lfs_object, :with_file)
        referenced_lfs_object = create(:lfs_object)
        create(:lfs_objects_project, lfs_object: referenced_lfs_object)

        expect { subject.perform }.to change(Geo::LfsObjectDeletedEvent, :count).by(2)
        expect(Geo::LfsObjectDeletedEvent.where(lfs_object: unreferenced_lfs_object_1.id)).to exist
        expect(Geo::LfsObjectDeletedEvent.where(lfs_object: unreferenced_lfs_object_2.id)).to exist
        expect(Geo::LfsObjectDeletedEvent.where(lfs_object: referenced_lfs_object.id)).not_to exist
      end
    end
  end
end
