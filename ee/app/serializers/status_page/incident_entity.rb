# frozen_string_literal: true

module StatusPage
  # Note: Any new fields exposures should also be added to
  # +StatusPage::TriggerPublishService::PUBLISH_WHEN_ISSUE_CHANGED+.
  class IncidentEntity < Grape::Entity
    expose :iid, as: :id
    expose :state, as: :status
    expose(:title) { |entity| StatusPage::Renderer.markdown(entity, :title, issue_iid: entity.iid) }
    expose(:description) { |entity| StatusPage::Renderer.markdown(entity, :description, issue_iid: entity.iid) }
    expose :updated_at
    expose :created_at
    expose :user_notes, as: :comments, using: IncidentCommentEntity
    expose :links

    private

    def links
      { details: Gitlab::StatusPage::Storage.details_path(object.iid) }
    end

    def user_notes
      Array(options[:user_notes])
    end
  end
end
