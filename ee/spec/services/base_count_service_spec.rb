# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BaseCountService do
  include ::EE::GeoHelpers

  describe '#cache_options' do
    subject { described_class.new.cache_options }

    it 'returns the default' do
      stub_current_geo_node(nil)

      is_expected.to include(:raw)
      is_expected.not_to include(:expires_in)
    end

    it 'returns default on a Geo primary' do
      stub_current_geo_node(create(:geo_node, :primary))

      is_expected.to include(:raw)
      is_expected.not_to include(:expires_in)
    end

    it 'returns cache of 20 mins on a Geo secondary' do
      stub_current_geo_node(create(:geo_node))

      is_expected.to include(:raw)
      is_expected.to include(expires_in: 20.minutes)
    end
  end

  describe '#delete_cache', :use_clean_rails_memory_store_caching do
    subject(:service) { described_class.new }

    before do
      allow(service)
        .to receive(:cache_key)
        .and_return('foo')

      allow(service)
        .to receive(:uncached_count)
        .and_return(4)

      service.refresh_cache
    end

    context 'on a Geo primary' do
      before do
        stub_primary_node
      end

      context 'when a Geo secondary node exists' do
        it 'creates a Geo::CacheInvalidationEvent' do
          allow(::Gitlab::Geo).to receive(:secondary_nodes).and_return(double(any?: true))

          expect do
            service.delete_cache
          end.to change { Geo::CacheInvalidationEvent.count }.by(1)
        end
      end

      context 'when there are no Geo secondary nodes' do
        it 'does not create a Geo::CacheInvalidationEvent' do
          allow(::Gitlab::Geo).to receive(:secondary_nodes).and_return(double(any?: false))

          expect do
            service.delete_cache
          end.not_to change { Geo::CacheInvalidationEvent.count }
        end
      end
    end

    context 'on a Geo secondary' do
      before do
        stub_secondary_node
      end

      it 'does not create a Geo::CacheInvalidationEvent' do
        expect do
          service.delete_cache
        end.not_to change { Geo::CacheInvalidationEvent.count }
      end
    end

    context 'without Geo' do
      it 'does not create a Geo::CacheInvalidationEvent' do
        expect do
          service.delete_cache
        end.not_to change { Geo::CacheInvalidationEvent.count }
      end
    end
  end
end
