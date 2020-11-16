# frozen_string_literal: true

class UserPermissionUpload < ApplicationRecord
  include FileStoreMounter

  belongs_to :user

  mount_file_store_uploader AttachmentUploader

  validates :status, presence: true
  validates :file, presence: true, if: :finished?

  state_machine :status, initial: :created do
    event :start do
      transition created: :running
    end

    event :finish do
      transition running: :finished
    end

    event :failed do
      transition [:created, :running] => :failed
    end

    state :created
    state :running
    state :finished
    state :failed
  end
end
