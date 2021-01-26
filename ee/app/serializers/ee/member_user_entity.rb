# frozen_string_literal: true

module EE
  module MemberUserEntity
    extend ActiveSupport::Concern

    prepended do
      unexpose :gitlab_employee
      unexpose :email
    end
  end
end
