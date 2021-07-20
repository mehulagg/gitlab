# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Cache do
  include ::EE::GeoHelpers

  describe '.delete' do
    let(:key) { %w{a cache key} }

    subject(:delete) { described_class.delete(key) }

    it 'calls Rails.cache.delete' do
      expect(Rails.cache).to receive(:delete).with(key)

      delete
    end

    it 'calls .delete_on_geo_secondaries' do
      expect(described_class).to receive(:delete_on_geo_secondaries).with(key)

      delete
    end
  end

  describe '.delete_on_geo_secondaries' do
    let(:key) { %w{a cache key} }

    subject(:delete_on_geo_secondaries) { described_class.delete_on_geo_secondaries(key) }

    context 'without Geo' do
      it 'does not create a Geo::CacheInvalidationEvent' do
        expect do
          delete_on_geo_secondaries
        end.not_to change { ::Geo::CacheInvalidationEvent.count }
      end
    end

    context 'for a Geo primary site' do
      before do
        stub_primary_node
      end

      context 'when there is at least one Geo secondary site' do
        before do
          allow(::Gitlab::Geo).to receive(:secondary_nodes).and_return(double(any?: true))
        end

        it 'creates a Geo::CacheInvalidationEvent' do
          expect do
            delete_on_geo_secondaries
          end.to change { ::Geo::CacheInvalidationEvent.count }.by(1)
        end
      end

      context 'when there are no Geo secondary sites' do
        before do
          allow(::Gitlab::Geo).to receive(:secondary_nodes).and_return(double(any?: false))
        end

        it 'does not create a Geo::CacheInvalidationEvent' do
          expect do
            delete_on_geo_secondaries
          end.not_to change { ::Geo::CacheInvalidationEvent.count }
        end
      end
    end

    context 'for a Geo secondary site' do
      before do
        stub_secondary_node
      end

      context 'when there is at least one Geo secondary site' do
        before do
          allow(::Gitlab::Geo).to receive(:secondary_nodes).and_return(double(any?: true))
        end

        it 'does not create a Geo::CacheInvalidationEvent' do
          expect do
            delete_on_geo_secondaries
          end.not_to change { ::Geo::CacheInvalidationEvent.count }
        end
      end
    end
  end
end
