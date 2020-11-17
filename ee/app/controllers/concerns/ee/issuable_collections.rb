# frozen_string_literal: true

module EE
  module IssuableCollections
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    override :preload_for_collection
    def preload_for_collection
      @preload_for_collection ||= case collection_type
                                  when 'MergeRequest'
                                    super.push(:approval_rules)
                                  when 'Issue'
                                    super.push(*issue_preloads)
                                  else
                                    super
                                  end
    end

    private

    def issue_preloads
      [].tap do |issue_params|
        issue_params << :epic_issue if params[:include_subepics].present?
      end
    end
  end
end
