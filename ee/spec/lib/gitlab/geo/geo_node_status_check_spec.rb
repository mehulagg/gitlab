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

    it 'prints messages for all legacy replication and verification checks' do
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
      ]

      checks.each do |text|
        expect { subject.print_replication_verification_status }.to output(text).to_stdout
      end
    end

    context 'Replicators' do
      let(:replicators) { Gitlab::Geo.enabled_replicator_classes }

      context 'replication' do
        let(:checks) do
          replicators.map { |k| /#{k.replicable_title_plural}:/ }
        end

        it 'prints messages for replication' do
          checks.each do |text|
            expect { subject.print_replication_verification_status }.to output(text).to_stdout
          end
        end
      end

      context 'verification' do
        let(:checks) do
          replicators.map { |k| /#{k.replicable_title_plural} Checked:/ }
        end

        context 'when verification is enabled' do
          it 'prints messages for verification checks' do
            checks.each do |text|
              expect { subject.print_replication_verification_status }.to output(text).to_stdout
            end
          end
        end

        context 'when verification is disabled' do
          it 'does not print messages for verification checks' do
            replicators.each do |replicator|
              allow(replicator).to receive(:verification_enabled?).and_return(false)
            end

            checks.each do |text|
              expect { subject.print_replication_verification_status }.not_to output(text).to_stdout
            end
          end
        end
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
