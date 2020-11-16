# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Geo::GeoNodeStatusCheck do
  let(:current_node) { create(:geo_node) }
  let(:geo_node_status) do
    build(:geo_node_status, :replicated_and_verified, geo_node: current_node)
  end

  let(:subject) { described_class.new(geo_node_status, current_node) }

  describe '#replication_verification_complete?' do
    before do
      allow(Gitlab.config.geo.registry_replication).to receive(:enabled).and_return(true)
    end

    it 'prints messages for all verification checks' do
      checks = [
        /Repositories: /,
        /Verified Repositories: /,
        /Wikis: /,
        /Verified Wikis: /,
        /LFS Objects: /,
        /Attachments: /,
        /CI job artifacts: /,
        /Container repositories: /,
        /Design repositories: /,
        /Repositories Checked: /
      ] + Gitlab::Geo.enabled_replicator_classes.map { |k| /#{k.replicable_title_plural} Checked:/ } +
          Gitlab::Geo.enabled_replicator_classes.map { |k| /#{k.replicable_title_plural}:/ }

      checks.each do |text|
        expect { subject.print_replication_verification_status }.to output(text).to_stdout
      end
    end

    context 'when replication is up-to-date' do
      it 'returns true' do
        expect(subject.replication_verification_complete?).to be_truthy
      end
    end

    context 'when replication is not up-to-date' do
      it 'returns false when not all replicables were synced' do
        geo_node_status.update!(repositories_synced_count: 5)

        expect(subject.replication_verification_complete?).to be_falsy
      end
    end
  end
end
