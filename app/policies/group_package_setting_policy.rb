# frozen_string_literal: true

class GroupPackageSettingPolicy < BasePolicy
  delegate { @subject.group }
end
