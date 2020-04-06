# frozen_string_literal: true

class NoteUserEntity < UserEntity
  expose :gitlab_employee?, as: :is_gitlab_employee, if: ->(user, options) { user.gitlab_employee? }

  unexpose :web_url
end
