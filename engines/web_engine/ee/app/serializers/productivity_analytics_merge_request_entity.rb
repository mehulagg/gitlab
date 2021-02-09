# frozen_string_literal: true

class ProductivityAnalyticsMergeRequestEntity < IssuableEntity
  ProductivityAnalytics::METRIC_TYPES.each do |type|
    expose(type) { |mr| mr.attributes[type] }
  end

  expose :author_avatar_url do |merge_request|
    merge_request.author&.avatar_url
  end

  expose :merge_request_url do |merge_request|
    project_merge_request_url(merge_request.target_project, merge_request)
  end
end
