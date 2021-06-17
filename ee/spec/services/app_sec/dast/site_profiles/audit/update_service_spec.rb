# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AppSec::Dast::SiteProfiles::Audit::UpdateService do
  let_it_be(:profile) { create(:dast_site_profile) }
  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user) }

  describe '#execute' do
    it 'audits the changes in the given properties', :aggregate_failures do
      auditor = described_class.new(project, user, {
        dast_site_profile: profile,
        new_params: { name: 'Updated DAST profile' },
        old_params: { name: 'Old DAST profile' }
      })

      auditor.execute

      audit_event = AuditEvent.find_by(author_id: user.id)
      expect(audit_event.author).to eq(user)
      expect(audit_event.entity).to eq(project)
      expect(audit_event.target_id).to eq(profile.id)
      expect(audit_event.target_type).to eq('DastSiteProfile')
      expect(audit_event.details[:custom_message]).to eq(
        'Changed DAST site profile name from Old DAST profile to Updated DAST profile'
      )
    end

    it 'omits the values for secret properties' do
      auditor = described_class.new(project, user, {
        dast_site_profile: profile,
        new_params: { auth_password: 'newpassword', request_headers: 'A new header' },
        old_params: { auth_password: 'oldpassword', request_headers: 'An old header' }
      })

      auditor.execute

      audit_events = AuditEvent.where(author_id: user.id)
      audit_events_messages = audit_events.map(&:details).pluck(:custom_message)
      expect(audit_events_messages).to contain_exactly(
        'Changed DAST site profile auth_password (secret value omitted)',
        'Changed DAST site profile request_headers (secret value omitted)'
      )
    end

    it 'omits the values for properties too long to be displayed' do
      auditor = described_class.new(project, user, {
        dast_site_profile: profile,
        new_params: { excluded_urls: ['https://target.test/signout'] },
        old_params: { excluded_urls: ['https://target.test/signin'] }
      })

      auditor.execute

      audit_event = AuditEvent.find_by(author_id: user.id)
      expect(audit_event.details[:custom_message]).to eq(
        'Changed DAST site profile excluded_urls (long value omitted)'
      )
    end

    it 'sorts properties that are arrays before comparing them' do
      auditor = described_class.new(project, user, {
        dast_site_profile: profile,
        new_params: { excluded_urls: ['https://target.test/signin', 'https://target.test/signout'] },
        old_params: { excluded_urls: ['https://target.test/signout', 'https://target.test/signin'] }
      })

      expect { auditor.execute }.not_to change { AuditEvent.count }
    end
  end
end
