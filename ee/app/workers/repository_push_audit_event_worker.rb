# frozen_string_literal: true

class RepositoryPushAuditEventWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker

  feature_category :authentication_and_authorization

  def perform(changes, project_id, user_id)
    project = Project.find(project_id)
    user = User.find(user_id)

    changes.map! do |change|
      before = change['before']
      after = change['after']
      ref = change['ref']

      service = EE::AuditEvents::RepositoryPushAuditEventService
        .new(user, project, ref, before, after)
        .tap { |event| event.prepare_security_event }

      # Checking if it's enabled and reusing the changes array
      # is mostly a memory optimization.
      service if service.enabled?
    end.compact!

    EE::AuditEvents::BulkInsertService.new(changes).execute
  end
end
