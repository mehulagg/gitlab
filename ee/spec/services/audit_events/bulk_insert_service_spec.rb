# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AuditEvents::BulkInsertService do
  let(:user) { create(:user) }
  let(:entity) { create(:project) }
  let(:entity_type) { 'Project' }
  let(:target_ref) { 'refs/heads/master' }
  let(:from) { 'b6bce79c3a8cb367877b53e315799b69acb700d7' }
  let(:to) { 'a7bce79c3a8cb367877b53e315799b69acb700fo' }
  let!(:collection) do
    Array.new(3).map do
      AuditEvents::RepositoryPushAuditEventService.new(user, entity, target_ref, from, to)
    end
  end

  let(:timestamp) { Time.zone.local(2019, 10, 10) }
  let(:attrs) do
    {
      author_id: user.id,
      entity_id: entity.id,
      entity_type: entity_type,
      created_at: timestamp,
      details: {
        updated_ref: project.default_branch,
        author_name: user.name,
        from: 'b6bce79c',
        to: 'a7bce79c',
        target_details: entity.full_path
      }
    }
  end

  let(:service) { described_class.new(collection) }

  describe '#execute' do
    it 'persists audit events' do
      travel_to(timestamp) { service.execute }

      events_attributes = AuditEvent.all.map { |event| event.attributes.deep_symbolize_keys }

      expect(AuditEvent.count).to eq(3)
      expect(events_attributes).to all(include(attrs))
    end

    it 'writes logs' do
      collection.each do |service| # rubocop:disable RSpec/IteratedExpectation
        expect(service).to receive(:log_security_event_to_file).and_call_original
      end

      service.execute
    end
  end
end
