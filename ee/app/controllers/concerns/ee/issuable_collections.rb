# frozen_string_literal: true

module EE
  module IssuableCollections
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    override :preload_for_collection
    def preload_for_collection
      @preload_for_collection ||= case collection_type
                                  when 'MergeRequest'
                                    super + [approval_rules: [:users, :group_users], approval_project_rules: [:users, :group_users]]
                                  when 'Issue'
                                    super + issue_preloads
                                  else
                                    super
                                  end
    end

    private

    # rubocop:disable Gitlab/ModuleWithInstanceVariables
    def iterations_available?
      return false if @project.blank?

      @project.licensed_feature_available?(:iterations)
    end
    # rubocop:enable Gitlab/ModuleWithInstanceVariables

    def issue_preloads
      [].tap do |issue_params|
        issue_params << :epic_issue if params[:include_subepics].present?
        issue_params << :iteration if iterations_available?
      end
    end
  end
end
