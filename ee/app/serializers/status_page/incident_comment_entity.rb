# frozen_string_literal: true

module StatusPage
  class IncidentCommentEntity < Grape::Entity
    expose(:note) { |entity| StatusPage::Renderer.markdown(entity, :note, issue_iid: options[:issue_iid]) }
    expose :created_at
  end
end
