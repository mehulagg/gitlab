# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AuditEvents::BuildService do
  let(:author) { build(:author, current_sign_in_ip: '127.0.0.1') }
  let(:scope) { build(:group) }
  let(:target) { build(:project) }
  let(:ip_address) { '192.168.8.8' }
  let(:message) { 'Added an interesting field from project Gotham' }

  subject(:service) do
    described_class.new(
      author: author,
      scope: scope,
      target: target,
      ip_address: ip_address,
      message: message
    )
  end

  describe '#execute' do
    subject(:event) { service.execute }

    context 'when licensed' do
      before do
        stub_licensed_features(admin_audit_log: true)
      end

      it 'sets correct attributes', :aggregate_failures do
        freeze_time do
          expect(event).to have_attributes(
            author_id: author.id,
            author_name: author.name,
            entity_id: scope.id,
            entity_type: scope.class.name
          )

          expect(event.details).to eq(
            author_name: author.name,
            target_id: target.id,
            target_type: target.class.name,
            target_details: target.name,
            custom_message: message,
            ip_address: ip_address,
            entity_path: scope.full_path
          )

          expect(event.ip_address).to eq(ip_address)
          expect(event.created_at).to eq(DateTime.current)
        end
      end

      context 'when IP address is not provided' do
        let(:ip_address) { nil }

        it 'uses author current_sign_in_ip' do
          expect(event.ip_address).to eq(author.current_sign_in_ip)
        end
      end
    end

    context 'when not licensed' do
      before do
        stub_licensed_features(admin_audit_log: false)
      end

      it 'sets correct attributes', :aggregate_failures do
        freeze_time do
          expect(event).to have_attributes(
            author_id: author.id,
            author_name: author.name,
            entity_id: scope.id,
            entity_type: scope.class.name
          )

          expect(event.details).to eq(
            author_name: author.name,
            target_id: target.id,
            target_type: target.class.name,
            target_details: target.name,
            custom_message: message
          )

          expect(event.ip_address).to be_nil
          expect(event.created_at).to eq(DateTime.current)
        end
      end
    end
  end
end
