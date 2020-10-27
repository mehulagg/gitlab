# frozen_string_literal: true

RSpec.shared_examples 'repository storage moveable' do |container_klass, worker|
  let(:factory_klass) { described_class.model_name.param_key }

  describe 'associations' do
    it { is_expected.to belong_to(container_klass) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(container_klass) }
    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to validate_presence_of(:source_storage_name) }
    it { is_expected.to validate_presence_of(:destination_storage_name) }

    context 'source_storage_name inclusion' do
      subject { build(factory_klass, source_storage_name: 'missing') }

      it "does not allow repository storages that don't match a label in the configuration" do
        expect(subject).not_to be_valid
        expect(subject.errors[:source_storage_name].first).to match(/is not included in the list/)
      end
    end

    context 'destination_storage_name inclusion' do
      subject { build(factory_klass, destination_storage_name: 'missing') }

      it "does not allow repository storages that don't match a label in the configuration" do
        expect(subject).not_to be_valid
        expect(subject.errors[:destination_storage_name].first).to match(/is not included in the list/)
      end
    end

    context "#{container_klass} repository read-only" do
      let(:container) { build(container_klass, repository_read_only: true) }

      subject { build(factory_klass, container_klass => container) }

      it "does not allow the #{container_klass} to be read-only on create" do
        expect(subject).not_to be_valid
        expect(subject.errors[container_klass].first).to match(/is read only/)
      end
    end
  end

  describe 'defaults' do
    context 'destination_storage_name' do
      subject { build(factory_klass) }

      it 'picks storage from ApplicationSetting' do
        expect(Gitlab::CurrentSettings).to receive(:pick_repository_storage).and_return('picked').at_least(:once)

        expect(subject.destination_storage_name).to eq('picked')
      end
    end
  end

  describe 'state transitions' do
    let(:container) { create(container_klass, :repository) }

    before do
      stub_storage_settings('test_second_storage' => { 'path' => 'tmp/tests/extra_storage' })
    end

    context 'when in the default state' do
      subject(:storage_move) { create(factory_klass, container_klass => container, destination_storage_name: 'test_second_storage') }

      context 'and transits to scheduled' do
        it "triggers #{worker}" do
          expect(worker).to receive(:perform_async).with(container.id, 'test_second_storage', storage_move.id)

          storage_move.schedule!

          expect(container).to be_repository_read_only
        end
      end

      context 'and transits to started' do
        it 'does not allow the transition' do
          expect { storage_move.start! }
            .to raise_error(StateMachines::InvalidTransition)
        end
      end
    end

    context 'when started' do
      subject(:storage_move) { create(factory_klass, :started, container_klass => container, destination_storage_name: 'test_second_storage') }

      context 'and transits to replicated' do
        it "sets the repository storage and marks #{container_klass} as writable" do
          storage_move.finish_replication!

          expect(container.repository_storage).to eq('test_second_storage')
          expect(container).not_to be_repository_read_only
        end
      end

      context 'and transits to failed' do
        it "marks the #{container_klass} as writable" do
          storage_move.do_fail!

          expect(container).not_to be_repository_read_only
        end
      end
    end
  end
end
