# frozen_string_literal: true

class BoardAssigneeEntity < Grape::Entity
  expose :id
  expose :name
  expose :username
  expose :avatar_url
end
