# frozen_string_literal: true

class GroupPackageSetting < ApplicationRecord
  self.primary_key = :group_id

  belongs_to :group, inverse_of: :group_package_setting

  validates :group, presence: true
  validates :maven_duplicates_allowed, inclusion: { in: [true, false] }
  validates :maven_duplicate_exception_regex, untrusted_regexp: true
end
