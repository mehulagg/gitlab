# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LfsObject do
  include EE::GeoHelpers

  describe '#destroy' do
    subject { create(:lfs_object, :with_file) }

    context 'when running in a Geo primary node' do
      let_it_be(:primary) { create(:geo_node, :primary) }
      let_it_be(:secondary) { create(:geo_node) }

      it 'logs an event to the Geo event log' do
        stub_current_geo_node(primary)

        expect { subject.destroy }.to change(Geo::LfsObjectDeletedEvent, :count).by(1)
      end
    end
  end
end
