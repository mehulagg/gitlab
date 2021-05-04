# frozen_string_literal: true

module AuthorizedProjectUpdate
  class RefreshProjectAuthorizationsService
    # Service for refreshing all the authorizations to a particular project.
    include Gitlab::Utils::StrongMemoize

    def initialize(project)
      @project = project
    end

    def execute
      until uuid = lease.try_obtain
        sleep(0.1)
      end

      begin
        execute_without_lease
      ensure
        Gitlab::ExclusiveLease.cancel(lease_key, uuid)
      end
    end

    def execute_without_lease
      refresh_authorizations
      ServiceResponse.success
    end

    private

    attr_reader :project

    def lease_key
      "refresh_project_authorizations:#{project.id}"
    end

    def lease
      Gitlab::ExclusiveLease.new(lease_key, timeout: 1.minute.to_i)
    end

    def current_authorizations
      strong_memoize(:current_authorizations) do
        project.project_authorizations
          .pluck(:user_id, :access_level) # rubocop: disable CodeReuse/ActiveRecord
      end
    end

    def fresh_authorizations
      strong_memoize(:fresh_authorizations) do
        Projects::Members::EffectiveAccessLevelService.new(project)
          .execute
          .map { |authorization| [authorization.user_id, authorization.access_level] }
      end
    end

    def user_ids_to_remove
      strong_memoize(:user_ids_to_remove) do
        (current_authorizations - fresh_authorizations)
          .map {|element| element.first }
      end
    end

    def authorizations_to_create
      strong_memoize(:authorizations_to_create) do
        (fresh_authorizations - current_authorizations).map do |element|
          {
            user_id: element.first,
            access_level: element.last,
            project_id: project.id
          }
        end
      end
    end

    def refresh_authorizations
      ProjectAuthorization.transaction do
        if user_ids_to_remove.any?
          ProjectAuthorization.where(project_id: project.id, user_id: user_ids_to_remove) # rubocop: disable CodeReuse/ActiveRecord
                              .delete_all
        end

        if authorizations_to_create.any?
          ProjectAuthorization.insert_all(authorizations_to_create)
        end
      end
    end
  end
end
