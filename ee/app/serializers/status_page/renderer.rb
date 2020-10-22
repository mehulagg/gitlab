# frozen_string_literal: true

module StatusPage
  module Renderer
    def self.markdown(object, field, issue_iid:)
      context = {
        post_process_pipeline: Gitlab::StatusPage::Pipeline::PostProcessPipeline,
        issue_iid: issue_iid
      }
      MarkupHelper.markdown_field(object, field, context)
    end
  end
end
