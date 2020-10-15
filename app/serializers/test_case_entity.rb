# frozen_string_literal: true

class TestCaseEntity < Grape::Entity
  include API::Helpers::RelatedResourcesHelpers

  expose :status
  expose :name
  expose :classname
  expose :file
  expose :execution_time
  expose :system_output
  expose :stack_trace
  expose :recent_failures
  expose :attachment_url, if: -> (*) { can_read_screenshots? } do |test_case|
    expose_url(test_case.attachment_url)
  end

  private

  alias_method :test_case, :object

  def recent_failures
    rand(5)
  end

  def can_read_screenshots?
    Feature.enabled?(:junit_pipeline_screenshots_view, options[:project]) && test_case.has_attachment?
  end
end
