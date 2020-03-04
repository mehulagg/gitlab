# frozen_string_literal: true

# Copy AwardEmoji from one awardable to another.
#
# This service expects the calling class to have performed the necessary
# authorization checks in order to allow the copy to happen.
module AwardEmojis
  class CopyService < ::BaseService
    def initialize(old_awardable, new_awardable)
      super(project = nil)

      @old_awardable = old_awardable
      @new_awardable = new_awardable
    end

    def execute
      old_awardable.award_emoji.each do |award|
        new_award = award.dup
        new_award.awardable = new_awardable
        new_award.save
      end

      success()
    end

    private

    attr_accessor :old_awardable, :new_awardable
  end
end
