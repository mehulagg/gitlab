# frozen_string_literal: true

module EE
  module API
    module Helpers
      module SettingsHelpers
        extend ActiveSupport::Concern

        prepended do
          params :optional_params_ee do
            optional :elasticsearch_indexing, type: Grape::API::Boolean, desc: 'Enable Elasticsearch indexing'

            given elasticsearch_indexing: ->(val) { val } do
              optional :elasticsearch_search, type: Grape::API::Boolean, desc: 'Enable Elasticsearch search'
              optional :elasticsearch_limit_indexing, type: Grape::API::Boolean, desc: 'Limit Elasticsearch to index certain namespaces and projects'
            end

            given elasticsearch_limit_indexing: ->(val) { val } do
              optional :elasticsearch_namespace_ids, type: Array[Integer], coerce_with: ::API::Validations::Types::LabelsList.coerce, desc: 'The namespace ids to index with Elasticsearch.'
              optional :elasticsearch_project_ids, type: Array[Integer], coerce_with: ::API::Validations::Types::LabelsList.coerce, desc: 'The project ids to index with Elasticsearch.'
            end

            optional :email_additional_text, type: String, desc: 'Additional text added to the bottom of every email for legal/auditing/compliance reasons'
            optional :default_project_deletion_protection, type: Grape::API::Boolean, desc: 'Disable project owners ability to delete project'
            optional :deletion_adjourned_period, type: Integer, desc: 'Number of days between marking project as deleted and actual removal'
            optional :help_text, type: String, desc: 'GitLab server administrator information'
            optional :repository_size_limit, type: Integer, desc: 'Size limit per repository (MB)'
            optional :file_template_project_id, type: Integer, desc: 'ID of project where instance-level file templates are stored.'
            optional :repository_storages, type: Array[String], desc: 'A list of names of enabled storage paths, taken from `gitlab.yml`. New projects will be created in one of these stores, chosen at random.'
            optional :usage_ping_enabled, type: Grape::API::Boolean, desc: 'Every week GitLab will report license usage back to GitLab, Inc.'
            optional :updating_name_disabled_for_users, type: Grape::API::Boolean, desc: 'Flag indicating if users are permitted to update their profile name'
            optional :disable_overriding_approvers_per_merge_request, type: Grape::API::Boolean, desc: 'Disable Users ability to overwrite approvers in merge requests.'
            optional :prevent_merge_requests_author_approval, type: Grape::API::Boolean, desc: 'Disable Merge request author ability to approve request.'
            optional :prevent_merge_requests_committers_approval, type: Grape::API::Boolean, desc: 'Disable Merge request committer ability to approve request.'
            optional :npm_package_requests_forwarding, type: Grape::API::Boolean, desc: 'NPM package requests are forwarded to npmjs.org if not found on GitLab.'
          end
        end

        class_methods do
          extend ::Gitlab::Utils::Override

          override :optional_attributes
          def optional_attributes
            super + EE::ApplicationSettingsHelper.possible_licensed_attributes
          end
        end
      end
    end
  end
end
