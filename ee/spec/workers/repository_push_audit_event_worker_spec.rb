# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RepositoryPushAuditEventWorker do
  describe '#perform' do
    let(:project) { create(:project, :repository) }
    let(:user) { create(:user) }
    let(:changes) do
      [
        {
          'before' => '123456',
          'after' => '789012',
          'ref' => 'refs/heads/tést'
        },
        {
          'before' => '654321',
          'after' => '210987',
          'ref' => 'refs/tags/tag'
        }
      ]
    end

    def event_attributes(details = {})
      {
        author_id: user.id,
        entity_id: project.id,
        entity_type: 'Project',
        details: details
      }
    end

    subject { described_class.new.perform(changes, project.id, user.id) }

    it 'audits events according to push changes' do
      subject

      branch_event = event_attributes(updated_ref: 'tést',
                                      author_name: user.name,
                                      from: '123456',
                                      to: '789012',
                                      target_details: project.full_path)

      tag_event = event_attributes(updated_ref: 'tag',
                                   author_name: user.name,
                                   from: '654321',
                                   to: '210987',
                                   target_details: project.full_path)

      events = AuditEvent.all.map do |event|
        event
          .attributes
          .deep_symbolize_keys
          .slice(:author_id, :entity_id, :entity_type, :details)
      end

      expect(events).to match_array([branch_event, tag_event])
    end

    context 'when feature is not available' do
      let(:changes) do
        [{
          'before' => '654321',
          'after' => '210987',
          'ref' => 'refs/tags/tag'
        }]
      end

      it 'does not create events' do
        expect_next_instance_of(AuditEvents::RepositoryPushAuditEventService) do |instance|
          expect(instance).to receive(:enabled?) { false }
        end

        expect { subject }.not_to change(AuditEvent, :count)
      end
    end
  end
end
