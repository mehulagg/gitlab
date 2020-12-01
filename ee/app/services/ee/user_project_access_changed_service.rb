# frozen_string_literal: true

module EE
  module UserProjectAccessChangedService
    def execute(blocking: true, priority: ::UserProjectAccessChangedService::HIGH_PRIORITY)
      result = super

      ::Gitlab::Database::LoadBalancing::Sticking.bulk_stick(:user, @user_ids) # rubocop:disable Gitlab/ModuleWithInstanceVariables

      result
    end
  end
end
