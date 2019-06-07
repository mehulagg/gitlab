# frozen_string_literal: true

class MergeTrain < ApplicationRecord
  include AfterCommitQueue

  belongs_to :merge_request
  belongs_to :user
  belongs_to :pipeline, class_name: 'Ci::Pipeline'

  delegate :project, to: :merge_request

  scope :ordered -> { order('merge_trains.id ASC') }

  class << self
    def all_in_train(merge_request)
      joined_merge_requests(merge_request).ordered
    end

    def first_in_train(merge_request)
      all_in_train(merge_request).first
    end

    def total_count_in_train(merge_request)
      all_in_train(merge_request).count
    end

    def joined_merge_requests(merge_request)
      MergeRequest.joins(:merge_train)
        .where('merge_requests.target_project_id = ?', merge_request.target_project_id)
        .where('merge_requests.target_branch = ?', merge_request.target_branch)
    end
  end

  def all_next
    self.class.all_in_train(merge_request).where('merge_trains.id > ?', id)
  end

  def index
    self.class.all_in_train(merge_request).where('merge_trains.id < ?', id).count
  end

  def first_in_train?
    !follower_in_train?
  end

  def follower_in_train?
    self.class.all_in_train(merge_request).where('merge_trains.id < ?', id).exists?
  end
end
