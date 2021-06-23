# frozen_string_literal: true

module Users
  class UpdateContributionHiddenWorker
    include ApplicationWorker

    feature_category :users
    idempotent!

    def perform(id, action)
      @banned_user = BannedUser.find_by(user_id: id)
      @user = User.find(id)

      case action
      when "ban"
        hide_issues
      when "unban"
        unhide_issues
      end
    end

    private

    def hide_issues

      if @banned_user.ban_state != "is_banned"
        while Issue.where(author_id: @user.id).where(hidden: false).count
          @user.issues.each_batch(of: 100) do |issues|
            issues.update_all(hidden: true)
          end
        end
      
        @banned_user.update_attribute(:ban_state, "is_banned")
      end

      "done"
    end

    def unhide_issues
      while !Issue.where(author_id: @user.id).where(hidden: true).count.nil?
        # if not banned or ban in prog, hide issues. when no more issues, update ban state to banned
        @user.issues.each_batch(of: 100) do |issues|
          issues.update_all(hidden: true)
        end
      end
      
      @banned_user.update_attribute(:ban_state, "is_banned")
    end
  end
end
