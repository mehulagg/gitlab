# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Database::LoadBalancing::Session do
  after do
    described_class.clear_session
  end

  describe '.current' do
    it 'returns the current session' do
      expect(described_class.current).to be_an_instance_of(described_class)
    end
  end

  describe '.clear_session' do
    it 'clears the current session' do
      described_class.current
      described_class.clear_session

      expect(RequestStore[described_class::CACHE_KEY]).to be_nil
    end
  end

  describe '#use_primary?' do
    it 'returns true when the primary should be used' do
      instance = described_class.new

      instance.use_primary!

      expect(instance.use_primary?).to eq(true)
    end

    it 'returns false when a secondary should be used' do
      expect(described_class.new.use_primary?).to eq(false)
    end

    it 'returns true when a write was performed' do
      instance = described_class.new

      instance.write!

      expect(instance.use_primary?).to eq(true)
    end
  end

  describe '#use_primary' do
    let(:instance) { described_class.new }

    context 'when primary was used before' do
      before do
        instance.write!
      end

      it 'restores state after use' do
        expect { |blk| instance.use_primary(&blk) }.to yield_with_no_args

        expect(instance.use_primary?).to eq(true)
      end
    end

    context 'when primary was not used' do
      it 'restores state after use' do
        expect { |blk| instance.use_primary(&blk) }.to yield_with_no_args

        expect(instance.use_primary?).to eq(false)
      end
    end

    it 'uses primary during block' do
      expect do |blk|
        instance.use_primary do
          expect(instance.use_primary?).to eq(true)

          # call yield probe
          blk.to_proc.call
        end
      end.to yield_control
    end

    it 'continues using primary when write was performed' do
      instance.use_primary do
        instance.write!
      end

      expect(instance.use_primary?).to eq(true)
    end
  end

  describe '#performed_write?' do
    it 'returns true if a write was performed' do
      instance = described_class.new

      instance.write!

      expect(instance.performed_write?).to eq(true)
    end
  end

  describe '#use_replica_if_possible' do
    let(:instance) { described_class.new }

    it 'uses replica during block' do
      expect do |blk|
        instance.use_replica_if_possible do
          expect(instance.use_replica?).to eq(true)

          # call yield probe
          blk.to_proc.call
        end
      end.to yield_control

      expect(instance.use_replica?).to eq(false)
    end

    it 'restores state after use' do
      expect do |blk|
        instance.use_replica_if_possible do
          instance.use_replica_if_possible do
            expect(instance.use_replica?).to eq(true)

            # call yield probe
            blk.to_proc.call
          end

          expect(instance.use_replica?).to eq(true)
        end
      end.to yield_control

      expect(instance.use_replica?).to eq(false)
    end

    context 'when primary was used before' do
      before do
        instance.use_primary!
      end

      it 'uses primary during block' do
        expect(instance.use_replica?).to eq(false)

        expect do |blk|
          instance.use_replica_if_possible do
            expect(instance.use_replica?).to eq(false)

            # call yield probe
            blk.to_proc.call
          end
        end.to yield_control

        expect(instance.use_replica?).to eq(false)
      end
    end

    context 'when a write was performed before' do
      before do
        instance.write!
      end

      it 'uses primary during block' do
        expect(instance.use_replica?).to eq(false)

        expect do |blk|
          instance.use_replica_if_possible do
            expect(instance.use_replica?).to eq(false)

            # call yield probe
            blk.to_proc.call
          end
        end.to yield_control

        expect(instance.use_replica?).to eq(false)
      end
    end

    context 'when primary was used inside the block' do
      it 'uses primary aterward' do
        expect(instance.use_replica?).to eq(false)

        instance.use_replica_if_possible do
          expect(instance.use_replica?).to eq(true)

          instance.use_primary!

          expect(instance.use_replica?).to eq(false)
        end

        expect(instance.use_replica?).to eq(false)
      end

      it 'restores state after use' do
        instance.use_replica_if_possible do
          instance.use_replica_if_possible do
            expect(instance.use_replica?).to eq(true)

            instance.use_primary!

            expect(instance.use_replica?).to eq(false)
          end

          expect(instance.use_replica?).to eq(false)
        end

        expect(instance.use_replica?).to eq(false)
      end
    end

    context 'when a write was performed inside the block' do
      it 'uses primary aterward' do
        expect(instance.use_replica?).to eq(false)

        instance.use_replica_if_possible do
          expect(instance.use_replica?).to eq(true)

          instance.write!

          expect(instance.use_replica?).to eq(false)
        end

        expect(instance.use_replica?).to eq(false)
      end

      it 'restores state after use' do
        instance.use_replica_if_possible do
          instance.use_replica_if_possible do
            expect(instance.use_replica?).to eq(true)

            instance.write!

            expect(instance.use_replica?).to eq(false)
          end

          expect(instance.use_replica?).to eq(false)
        end

        expect(instance.use_replica?).to eq(false)
      end
    end
  end
end
