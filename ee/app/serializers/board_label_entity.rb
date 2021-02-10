# frozen_string_literal: true

class BoardLabelEntity < Grape::Entity
  expose :id
  expose :color
  expose :title
end
