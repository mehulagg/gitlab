# frozen_string_literal: true

class GpgKeysFinder
  def initialize(**params)
    @params = params
  end

  def execute
    keys = GpgKey.all
    by_users(keys)
  end

  private

  attr_reader :params

  def by_users(keys)
    return keys unless params[:users]

    keys.for_user(params[:users])
  end
end
