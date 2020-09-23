# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Audit::Levels::Instance do
  describe '#apply' do
    let_it_be(:audit_events) do
      [
        create(:project_audit_event),
        create(:group_audit_event),
        create(:user_audit_event)
      ]
    end

    subject { described_class.new.apply }

    it 'finds all events' do
      expect(subject).to match_array(audit_events)
    end
  end
end
