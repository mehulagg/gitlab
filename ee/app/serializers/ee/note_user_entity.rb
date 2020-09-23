# frozen_string_literal: true

module EE
  module NoteUserEntity
    extend ActiveSupport::Concern

    prepended do
      expose :gitlab_employee?, as: :is_gitlab_employee, if: ->(user, options) { user.gitlab_employee? }
    end
  end
end
