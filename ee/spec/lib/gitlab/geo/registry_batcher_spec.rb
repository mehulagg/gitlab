# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Geo::RegistryBatcher, :geo, :use_clean_rails_memory_store_caching do
  include EE::GeoHelpers

  describe '#next_range!' do
    let(:model_class) { LfsObject }
    let(:model_foreign_key) { registry_class::MODEL_FOREIGN_KEY }
    let(:registry_class) { Geo::LfsObjectRegistry }
    let(:registry_class_factory) { registry_factory_name(registry_class) }
    let(:key) { 'looping_batcher_spec' }
    let(:batch_size) { 2 }

    subject { described_class.new(registry_class, key: key, batch_size: batch_size).next_range! }

    context 'when there are no records' do
      it { is_expected.to be_nil }
    end

    context 'when there are no records but there are orphaned registries' do
      let!(:registries) { create_list(registry_class_factory, 3) }

      context 'when it has never been called before' do
        it { is_expected.to be_a Range }

        it 'starts from the beginning' do
          expect(subject.first).to eq(1)
        end

        it 'ends at a full batch' do
          expect(subject.last).to eq(registries.second.public_send(model_foreign_key))
        end

        context 'when the batch size is greater than the number of registries' do
          let(:batch_size) { 5 }

          it 'ends at the last ID' do
            expect(subject.last).to eq(registries.last.public_send(model_foreign_key))
          end
        end
      end

      context 'when it was called before' do
        context 'when the previous batch included the end of the table' do
          before do
            described_class.new(registry_class, key: key, batch_size: registry_class.count).next_range!
          end

          it { is_expected.to be_nil }
        end

        context 'when the previous batch did not include the end of the table' do
          before do
            described_class.new(registry_class, key: key, batch_size: registry_class.count - 1).next_range!
          end

          it 'starts after the previous batch' do
            expect(subject).to eq(registries.last.public_send(model_foreign_key)..registries.last.public_send(model_foreign_key))
          end
        end

        context 'if cache is cleared' do
          before do
            described_class.new(registry_class, key: key, batch_size: batch_size).next_range!
          end

          it 'starts from the beginning' do
            Rails.cache.clear

            expect(subject).to eq(1..registries.second.public_send(model_foreign_key))
          end
        end
      end
    end

    context 'when there are records' do
      let!(:records) { create_list(model_class.underscore, 3) }

      context 'when it has never been called before' do
        it { is_expected.to be_a Range }

        it 'starts from the beginning' do
          expect(subject.first).to eq(1)
        end

        it 'ends at a full batch' do
          expect(subject.last).to eq(records.second.id)
        end

        context 'when the batch size is greater than the number of records' do
          let(:batch_size) { 5 }

          it 'ends at the last ID' do
            expect(subject.last).to eq(records.last.id)
          end
        end
      end

      context 'when it was called before' do
        context 'when the previous batch included the end of the table' do
          before do
            described_class.new(registry_class, key: key, batch_size: model_class.count).next_range!
          end

          it 'starts from the beginning' do
            expect(subject).to eq(1..records.second.id)
          end
        end

        context 'when the previous batch did not include the end of the table' do
          before do
            described_class.new(registry_class, key: key, batch_size: model_class.count - 1).next_range!
          end

          it 'starts after the previous batch' do
            expect(subject).to eq(records.last.id..records.last.id)
          end
        end

        context 'if cache is cleared' do
          before do
            described_class.new(registry_class, key: key, batch_size: batch_size).next_range!
          end

          it 'starts from the beginning' do
            Rails.cache.clear

            expect(subject).to eq(1..records.second.id)
          end
        end
      end
    end

    context 'when there are records and orphaned registries with foreign key greater than last record id' do
      let!(:records) { create_list(model_class.underscore, 3) }
      let(:orphaned_registry_foreign_key_id) { records.last.id }
      let!(:registry) { create(registry_class_factory, model_foreign_key => orphaned_registry_foreign_key_id) }

      before do
        model_class.where(id: orphaned_registry_foreign_key_id).delete_all
      end

      context 'when it has never been called before' do
        it { is_expected.to be_a Range }

        it 'starts from the beginning' do
          expect(subject.first).to eq(1)
        end

        it 'ends at the last registry foreign key ID' do
          expect(subject.last).to eq(orphaned_registry_foreign_key_id)
        end
      end

      context 'when it was called before' do
        before do
          described_class.new(registry_class, key: key, batch_size: batch_size).next_range!
        end

        it { is_expected.to be_nil }

        context 'if cache is cleared' do
          it 'starts from the beginning' do
            Rails.cache.clear

            expect(subject).to eq(1..orphaned_registry_foreign_key_id)
          end
        end
      end
    end
  end
end
