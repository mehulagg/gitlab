# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Epics::CreateService do
  let_it_be(:group) { create(:group, :internal)}
  let_it_be(:user) { create(:user) }
  let_it_be(:parent_epic) { create(:epic, group: group) }
  let(:params) { { title: 'new epic', description: 'epic description', parent_id: parent_epic.id, confidential: true } }

  subject { described_class.new(group, user, params).execute }

  describe '#execute' do
    it 'creates one epic correctly' do
      allow(NewEpicWorker).to receive(:perform_async)

      expect { subject }.to change { Epic.count }.by(1)

      epic = Epic.last
      expect(epic).to be_persisted
      expect(epic.title).to eq('new epic')
      expect(epic.description).to eq('epic description')
      expect(epic.parent).to eq(parent_epic)
      expect(epic.relative_position).not_to be_nil
      expect(epic.confidential).to be_truthy
      expect(NewEpicWorker).to have_received(:perform_async).with(epic.id, user.id)
    end
  end

  context 'handling fixed dates' do
    it 'sets the fixed date correctly' do
      date = Date.new(2019, 10, 10)
      params[:start_date_fixed] = date
      params[:start_date_is_fixed] = true

      subject

      epic = Epic.last
      expect(epic.start_date).to eq(date)
      expect(epic.start_date_fixed).to eq(date)
      expect(epic.start_date_is_fixed).to be_truthy
    end
  end

  context 'after_save callback to store_mentions' do
    let(:labels) { create_pair(:group_label, group: group) }

    context 'when mentionable attributes change' do
      context 'when content has no mentions' do
        let(:params) { { title: 'Title', description: "Description with no mentions" } }

        it 'calls store_mentions! and saves no mentions' do
          expect_next_instance_of(Epic) do |instance|
            expect(instance).to receive(:store_mentions!).and_call_original
          end

          expect { subject }.not_to change { EpicUserMention.count }
        end
      end

      context 'when content has mentions' do
        let(:params) { { title: 'Title', description: "Description with #{user.to_reference}" } }

        it 'calls store_mentions! and saves mentions' do
          expect_next_instance_of(Epic) do |instance|
            expect(instance).to receive(:store_mentions!).and_call_original
          end

          expect { subject }.to change { EpicUserMention.count }.by(1)
        end
      end

      context 'when mentionable.save fails' do
        let(:params) { { title: '', label_ids: labels.map(&:id) } }

        it 'does not call store_mentions and saves no mentions' do
          expect_next_instance_of(Epic) do |instance|
            expect(instance).not_to receive(:store_mentions!).and_call_original
          end

          expect { subject }.not_to change { EpicUserMention.count }
          expect(subject.valid?).to be false
        end
      end
    end
  end
end
