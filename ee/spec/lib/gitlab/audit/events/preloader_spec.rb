# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Audit::Events::Preloader do
  describe '.preload!' do
    let_it_be(:audit_events) { create_list(:audit_event, 2) }

    let(:audit_events_relation) { AuditEvent.where(id: audit_events.map(&:id)) }

    subject { described_class.preload!(audit_events_relation) }

    it 'returns an ActiveRecord::Relation' do
      expect(subject).to be_an(ActiveRecord::Relation)
    end

    it 'preloads associated records' do
      log = ActiveRecord::QueryRecorder.new do
        subject.map do |event|
          [event.author_name, event.lazy_entity.name]
        end
      end

      # Expected queries when requesting for AuditEvent with associated records
      #
      # 1. On the audit_events table
      #    SELECT "audit_events".* FROM "audit_events"
      # 2. On the users table for author_name
      #    SELECT "users".* FROM "users" WHERE "users"."id" IN (1, 3)
      # 3. On the users table for entity name
      #    SELECT "users".* FROM "users" WHERE "users"."id" IN (2, 4)
      #
      expect(log.count).to eq(3)
    end
  end
end
