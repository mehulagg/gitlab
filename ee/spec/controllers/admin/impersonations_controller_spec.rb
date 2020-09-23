# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Admin::ImpersonationsController do
  let(:impersonator) { create(:admin) }
  let(:user) { create(:user) }

  describe "DELETE destroy" do
    context "when signed in" do
      before do
        sign_in(user)
      end

      context "when impersonating" do
        before do
          session[:impersonator_id] = impersonator.id
          stub_licensed_features(extended_audit_events: true)
        end

        it 'creates an audit log record' do
          expect { delete :destroy }.to change { AuditEvent.count }.by(1)
        end
      end
    end
  end
end
