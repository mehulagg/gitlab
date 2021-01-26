# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Users::RejectService do
  let(:current_user) { create(:admin) }

  describe '#execute', :enable_admin_mode do
    let(:user) { create(:user, :blocked_pending_approval) }

    subject(:reject_user) { Users::RejectService.new(current_user).execute(user) }

    describe 'audit events' do
      context 'when licensed' do
        before do
          stub_licensed_features(admin_audit_log: true)
        end

        context 'when user is successfully rejected' do
          it 'logs an audit event' do
            expect { reject_user }.to change { AuditEvent.count }.by(1)
          end

          it 'logs the audit event info', :aggregate_failures do
            reject_user

            expect(AuditEvent.last.author_id).to eq(current_user.id)
            expect(AuditEvent.last.ip_address).to eq(current_user.current_sign_in_ip)
            expect(AuditEvent.last.details[:target_details]).to eq(user.username)
            expect(AuditEvent.last.details[:custom_message]).to eq("Instance request rejected")
          end
        end

        context 'when user rejection fails' do
          let(:current_user) { create(:user) }

          it 'does not log any audit event' do
            expect { reject_user }.not_to change { AuditEvent.count }
          end
        end
      end

      context 'when not licensed' do
        before do
          stub_licensed_features(admin_audit_log: false)
        end

        it 'does not log any audit event' do
          expect { reject_user }.not_to change(AuditEvent, :count)
        end
      end
    end
  end
end
