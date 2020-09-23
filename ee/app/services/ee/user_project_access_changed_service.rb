# frozen_string_literal: true

module EE
  module UserProjectAccessChangedService
    def execute(blocking: true, priority: ::UserProjectAccessChangedService::HIGH_PRIORITY)
      result = super

      @user_ids.each do |id| # rubocop:disable Gitlab/ModuleWithInstanceVariables
        ::Gitlab::Database::LoadBalancing::Sticking.stick(:user, id)
      end

      result
    end
  end
end
