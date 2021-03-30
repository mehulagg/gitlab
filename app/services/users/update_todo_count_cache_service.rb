# frozen_string_literal: true

module Users
  class UpdateTodoCountCacheService < BaseService
    QUERY_BATCH_SIZE = 10

    attr_reader :users

    # users - An array of User objects or user IDs
    def initialize(users)
      @users = users
    end

    def execute
      users.each_slice(QUERY_BATCH_SIZE) do |users_batch|
        Todo.where(state: [:done, :pending], user_id: users_batch).group(:user_id, :state).count.each do |(user_id, state), todos_count|
          expiration_time = users_by_id[user_id].count_cache_validity_period

          Rails.cache.write(['users', user_id, "todos_#{state}_count"], todos_count, expires_in: expiration_time)
        end
      end
    end

    private

    def users_by_id
      @users_by_id ||= users.index_by { |user| [user.id, user] }
    end
  end
end
