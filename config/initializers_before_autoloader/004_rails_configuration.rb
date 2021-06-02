# frozen_string_literal: true

Rails.application.configure do
  config.load_defaults '5.1'

  config.action_controller.forgery_protection_origin_check = false

  config.active_record.belongs_to_required_by_default = false
end
