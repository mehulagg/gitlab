# frozen_string_literal: true

module IncidentManagement
  class OncallScheduleEntity < Grape::Entity
    expose :name
    expose :project_name
  end
end
