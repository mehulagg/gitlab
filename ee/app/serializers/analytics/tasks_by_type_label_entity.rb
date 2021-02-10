# frozen_string_literal: true

module Analytics
  class TasksByTypeLabelEntity < Grape::Entity
    expose :label, with: LabelEntity
    expose :series
  end
end
