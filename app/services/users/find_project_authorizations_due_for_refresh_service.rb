# frozen_string_literal: true

module Users
  # Service for finding the authorized_projects records of a user that needs addition or removal.
  #
  # Usage:
  #
  #     user = User.find_by(username: 'alice')
  #     service = Users::FindProjectAuthorizationsDueForRefreshService.new(some_user)
  #     service.execute
  class FindProjectAuthorizationsDueForRefreshService
    def initialize(user, source: nil, incorrect_auth_found_callback: nil, missing_auth_found_callback: nil, log_details_of_find: true)
      @user = user
      @source = source
      @incorrect_auth_found_callback = incorrect_auth_found_callback
      @missing_auth_found_callback = missing_auth_found_callback
      @log_details_of_find = log_details_of_find

      # We need an up to date User object that has access to all relations that
      # may have been created earlier. The only way to ensure this is to reload
      # the User object.
      user.reset
    end

    def execute
      current = current_authorizations_per_project
      fresh = fresh_access_levels_per_project

      # Projects that have more than one authorizations associated with
      # the user needs to be deleted.
      # The correct authorization is added to the ``add`` array in the
      # next stage.
      remove = projects_with_duplicates
      current.except!(*projects_with_duplicates)

      remove |= current.each_with_object([]) do |(project_id, row), array|
        # rows not in the new list or with a different access level should be
        # removed.
        if !fresh[project_id] || fresh[project_id] != row.access_level
          if incorrect_auth_found_callback
            incorrect_auth_found_callback.call(project_id, row.access_level)
          end

          array << row.project_id
        end
      end

      add = fresh.each_with_object([]) do |(project_id, level), array|
        # rows not in the old list or with a different access level should be
        # added.
        if !current[project_id] || current[project_id].access_level != level
          if missing_auth_found_callback
            missing_auth_found_callback.call(project_id, level)
          end

          array << [user.id, project_id, level]
        end
      end

      log_details(remove, add)

      [remove, add]
    end

    def current_authorizations
      @current_authorizations ||= user.project_authorizations.select(:project_id, :access_level)
    end

    def fresh_authorizations
      Gitlab::ProjectAuthorizations.new(user).calculate
    end

    def current_authorizations_per_project
      current_authorizations.index_by(&:project_id)
    end

    def fresh_access_levels_per_project
      fresh_authorizations.each_with_object({}) do |row, hash|
        hash[row.project_id] = row.access_level
      end
    end

    private

    attr_reader :user, :source, :incorrect_auth_found_callback, :missing_auth_found_callback, :log_details_of_find

    def projects_with_duplicates
      @projects_with_duplicates ||= current_authorizations
                                      .group_by(&:project_id)
                                      .select { |project_id, authorizations| authorizations.count > 1 }
                                      .keys
    end

    def log_details(remove, add)
      return unless should_be_logged?
      return unless any_detail_present_for_logging?(remove, add)

      Gitlab::AppJsonLogger.info(event: 'authorized_projects_due_for_refresh',
                                 user_id: user.id,
                                 'authorized_projects_due_for_refresh.source': source,
                                 'authorized_projects_due_for_refresh.rows_deleted_count': remove.length,
                                 'authorized_projects_due_for_refresh.rows_added_count': add.length,
                                 # most often there's only a few entries in remove and add, but limit it to the first 5
                                 # entries to avoid flooding the logs
                                 'authorized_projects_due_for_refresh.rows_deleted_slice': remove.first(5),
                                 'authorized_projects_due_for_refresh.rows_added_slice': add.first(5))
    end

    def should_be_logged?
      log_details_of_find
    end

    def any_detail_present_for_logging?(remove, add)
      remove.present? || add.present?
    end
  end
end
