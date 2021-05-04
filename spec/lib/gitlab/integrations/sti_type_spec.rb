# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Integrations::StiType do
  let(:types) { ['AsanaService', 'Integrations::Asana', Integrations::Asana.name] }

  describe '#serialize' do
    context 'SQL SELECT' do
      let(:expected_sql) {
        <<~SQL.strip
          SELECT "services".* FROM "services" WHERE "services"."type" = 'AsanaService'
        SQL
      }

      it 'forms SQL SELECT statements correctly' do
        sql_statements = types.map do |type|
          Service.where(type: type).to_sql
        end

        expect(sql_statements).to all(eq(expected_sql))
      end
    end

    context 'SQL CREATE' do
      let(:expected_sql) {
        <<~SQL.strip
          INSERT INTO "services" ("type") VALUES ('AsanaService')
        SQL
      }

      it 'forms SQL CREATE statements correctly' do
        sql_statements = types.map do |type|
          record = ActiveRecord::QueryRecorder.new { Service.insert({ type: type }) }
          record.log.first
        end

        expect(sql_statements).to all(include(expected_sql))
      end
    end

    context 'SQL UPDATE' do
      let(:expected_sql) {
        <<~SQL.strip
          UPDATE "services" SET "type" = 'AsanaService'
        SQL
      }

      let_it_be(:service) { create(:service) }

      it 'forms SQL UPDATE statements correctly' do
        sql_statements = types.map do |type|
          record = ActiveRecord::QueryRecorder.new { service.update_column(:type, type) }
          record.log.first
        end

        expect(sql_statements).to all(include(expected_sql))
      end
    end

    context 'SQL DELETE' do
      let(:expected_sql) {
        <<~SQL.strip
          DELETE FROM "services" WHERE "services"."type" = 'AsanaService'
        SQL
      }

      let(:service) { create(:service) }

      it 'forms SQL UPDATE statements correctly' do
        sql_statements = types.map do |type|
          record = ActiveRecord::QueryRecorder.new { Service.delete_by(type: type) }
          record.log.first
        end

        expect(sql_statements).to all(match(expected_sql))
      end
    end
  end

  describe '#deserialize' do
    specify 'it deserializes type correctly' do
      service = create(:service, type: 'Integrations::Asana')
      expect(service.type).to eq('AsanaService')
    end
  end

  describe '#cast_value' do
    it 'casts type as model correctly', :aggregate_failures do
      create(:service, type: 'AsanaService')

      types.each do |type|
        expect(Service.find_by(type: type)).to be_kind_of(Integrations::Asana)
      end
    end
  end

  describe '#changed?' do
    it 'detects changes correctly', :aggregate_failures do
      service = create(:service, type: 'AsanaService')

      types.each do |type|
        service.type = type

        expect(service).not_to be_changed
      end

      service.type = 'NewType'

      expect(service).to be_changed
    end
  end
end
