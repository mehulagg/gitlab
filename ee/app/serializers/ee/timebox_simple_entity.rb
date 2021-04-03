# frozen_string_literal: true

module EE
  class TimeboxSimpleEntity < Grape::Entity
    expose :id
    expose :title
  end
end
