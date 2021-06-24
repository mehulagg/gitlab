# frozen_string_literal: true
module Users
  class HideContributionsWorker
    include ApplicationWorker

    feature_category :users
    idempotent!

    def perform(id)
      user = User.find(id)

      hide_issues(user)
    end

    private

    def hide_issues(user)
      user.issues.each_batch(of: 100) do |issues|
        issues.update_all(hidden: true)
      end
    end
  end
end
