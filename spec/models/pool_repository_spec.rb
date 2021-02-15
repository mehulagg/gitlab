# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PoolRepository do
  describe 'associations' do
    it { is_expected.to belong_to(:shard) }
    it { is_expected.to belong_to(:source_project) }
    it { is_expected.to have_many(:member_projects) }
  end

  describe 'validations' do
    let!(:pool_repository) { create(:pool_repository) }

    it { is_expected.to validate_presence_of(:shard) }
    it { is_expected.to validate_presence_of(:source_project) }
  end

  describe '#disk_path' do
    it 'sets the hashed disk_path' do
      pool = create(:pool_repository)

      expect(pool.disk_path).to match(%r{\A@pools/\h{2}/\h{2}/\h{64}})
    end
  end

  describe '#update_if_source_is_leaving' do
    let_it_be_with_reload(:pool) { create(:pool_repository, :ready) }

    context 'when the deleted project is not the source' do
      let_it_be(:member_project) { create(:project, :repository, pool_repository: pool) }
      it 'does not update the source_project' do
        expect do
          pool.update_if_source_is_leaving(member_project)
        end.not_to change {pool.source_project}
      end
    end

    context 'when the deleted project is the source' do
      context 'when there are other member projects' do
        let_it_be(:member_project) { create(:project, :repository, pool_repository: pool) }
        it 'makes another member project the new source' do
          pool.update_if_source_is_leaving(pool.source_project)
          expect(pool.source_project.id).to eq(member_project.id)
        end
      end

      context 'when there are no other member projects' do
        it 'does not update the source project' do
          expect do
            pool.update_if_source_is_leaving(pool.source_project)
          end.not_to change {pool.source_project}
        end
      end
    end
  end

  describe '#mark_obsolete_if_last' do
    let(:pool) { create(:pool_repository, :ready) }

    context 'when the last member leaves' do
      it 'schedules pool removal' do
        expect(::ObjectPool::DestroyWorker).to receive(:perform_async).with(pool.id).and_call_original

        pool.mark_obsolete_if_last(pool.source_project.repository)
      end
    end

    context 'when the second member leaves' do
      it 'does not schedule pool removal' do
        create(:project, :repository, pool_repository: pool)
        expect(::ObjectPool::DestroyWorker).not_to receive(:perform_async).with(pool.id)

        pool.mark_obsolete_if_last(pool.source_project.repository)
      end
    end
  end
end
