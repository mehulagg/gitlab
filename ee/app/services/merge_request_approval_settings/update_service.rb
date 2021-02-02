# frozen_string_literal: true

module MergeRequestApprovalSettings
  class UpdateService < BaseContainerService
    def execute
      setting = GroupMergeRequestApprovalSetting.find_or_initialize_by_group(container)
      setting.assign_attributes(params)

      if setting.save
        ServiceResponse.success(payload: setting)
      else
        ServiceResponse.error(message: setting.errors.messages)
      end
    end
  end
end
