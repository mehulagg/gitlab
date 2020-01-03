# frozen_string_literal: true

module EE
  module API
    module Entities
      module EntityHelpers
        def can_read(attr, &block)
          ->(obj, opts) { Ability.allowed?(opts[:user], "read_#{attr}".to_sym, yield(obj)) }
        end

        def can_destroy(attr, &block)
          ->(obj, opts) { Ability.allowed?(opts[:user], "destroy_#{attr}".to_sym, yield(obj)) }
        end

        def expose_restricted(attr, &block)
          expose attr, if: can_read(attr, &block)
        end
      end

      module UserPublic
        extend ActiveSupport::Concern

        prepended do
          expose :shared_runners_minutes_limit
          expose :extra_shared_runners_minutes_limit
        end
      end

      module UserWithAdmin
        extend ActiveSupport::Concern

        prepended do
          expose :note
        end
      end

      module Project
        extend ActiveSupport::Concern

        prepended do
          expose :approvals_before_merge, if: ->(project, _) { project.feature_available?(:merge_request_approvers) }
          expose :mirror, if: ->(project, _) { project.feature_available?(:repository_mirrors) }
          expose :mirror_user_id, if: ->(project, _) { project.mirror? }
          expose :mirror_trigger_builds, if: ->(project, _) { project.mirror? }
          expose :only_mirror_protected_branches, if: ->(project, _) { project.mirror? }
          expose :mirror_overwrites_diverged_branches, if: ->(project, _) { project.mirror? }
          expose :external_authorization_classification_label,
                 if: ->(_, _) { License.feature_available?(:external_authorization_service_api_management) }
          expose :packages_enabled, if: ->(project, _) { project.feature_available?(:packages) }
          expose :service_desk_enabled, if: ->(project, _) { project.feature_available?(:service_desk) }
          expose :service_desk_address, if: ->(project, _) { project.feature_available?(:service_desk) }
          expose :marked_for_deletion_at, if: ->(project, _) { project.feature_available?(:adjourned_deletion_for_projects_and_groups) }
        end
      end

      module Group
        extend ActiveSupport::Concern

        prepended do
          expose :ldap_cn, :ldap_access
          expose :ldap_group_links,
                 using: EE::API::Entities::LdapGroupLink,
                 if: ->(group, options) { group.ldap_group_links.any? }

          expose :checked_file_template_project_id,
                 as: :file_template_project_id,
                 if: ->(group, options) { group.feature_available?(:custom_file_templates_for_namespace) }
          expose :marked_for_deletion_on, if: ->(group, _) { group.feature_available?(:adjourned_deletion_for_projects_and_groups) }
        end
      end

      module GroupDetail
        extend ActiveSupport::Concern

        prepended do
          expose :shared_runners_minutes_limit
          expose :extra_shared_runners_minutes_limit
        end
      end

      module Identity
        extend ActiveSupport::Concern

        prepended do
          expose :saml_provider_id
        end
      end

      module Member
        extend ActiveSupport::Concern

        prepended do
          expose :group_saml_identity,
                 using: ::API::Entities::Identity,
                 if: -> (member, options) { Ability.allowed?(options[:current_user], :read_group_saml_identity, member.source) }
          expose :is_using_seat, if: -> (_, options) { options[:show_seat_info] }
        end
      end

      module ProtectedRefAccess
        extend ActiveSupport::Concern

        prepended do
          expose :user_id
          expose :group_id
        end
      end

      module ProtectedBranch
        extend ActiveSupport::Concern

        prepended do
          expose :unprotect_access_levels, using: ::API::Entities::ProtectedRefAccess
          expose :code_owner_approval_required
        end
      end

      module IssueBasic
        extend ActiveSupport::Concern

        prepended do
          expose :weight, if: ->(issue, _) { issue.supports_weight? }
        end
      end

      module Issue
        extend ActiveSupport::Concern

        prepended do
          with_options if: -> (issue, options) { ::Ability.allowed?(options[:current_user], :read_epic, issue.project&.group) } do
            expose :epic_iid do |issue|
              issue.epic&.iid
            end

            expose :epic, using: EpicBaseEntity
          end
        end
      end

      module MergeRequestBasic
        extend ActiveSupport::Concern

        prepended do
          expose :approvals_before_merge
        end
      end

      module Namespace
        extend ActiveSupport::Concern

        prepended do
          can_admin_namespace = ->(namespace, opts) { ::Ability.allowed?(opts[:current_user], :admin_namespace, namespace) }

          expose :shared_runners_minutes_limit, if: ->(_, options) { options[:current_user]&.admin? }
          expose :extra_shared_runners_minutes_limit, if: ->(_, options) { options[:current_user]&.admin? }
          expose :billable_members_count do |namespace, options|
            namespace.billable_members_count(options[:requested_hosted_plan])
          end
          expose :plan, if: can_admin_namespace do |namespace, _|
            namespace.actual_plan_name
          end
          expose :trial_ends_on, if: can_admin_namespace do |namespace, _|
            namespace.trial_ends_on
          end
          expose :trial, if: can_admin_namespace do |namespace, _|
            namespace.trial?
          end
        end
      end

      module Board
        extend ActiveSupport::Concern

        prepended do
          # Default filtering configuration
          expose :name
          expose :group, using: ::API::Entities::BasicGroupDetails

          with_options if: ->(board, _) { board.resource_parent.feature_available?(:scoped_issue_board) } do
            expose :milestone do |board|
              if board.milestone.is_a?(Milestone)
                ::API::Entities::Milestone.represent(board.milestone)
              else
                SpecialBoardFilter.represent(board.milestone)
              end
            end
            expose :assignee, using: ::API::Entities::UserBasic
            expose :labels, using: ::API::Entities::LabelBasic
            expose :weight
          end
        end
      end

      module List
        extend ActiveSupport::Concern

        prepended do
          expose :milestone, using: ::API::Entities::Milestone, if: -> (entity, _) { entity.milestone? }
          expose :user, as: :assignee, using: ::API::Entities::UserSafe, if: -> (entity, _) { entity.assignee? }
          expose :max_issue_count, if: -> (list, _) { list.wip_limits_available? }
          expose :max_issue_weight, if: -> (list, _) { list.wip_limits_available? }
        end
      end

      module ApplicationSetting
        extend ActiveSupport::Concern

        prepended do
          expose(*EE::ApplicationSettingsHelper.repository_mirror_attributes, if: ->(_instance, _options) do
            ::License.feature_available?(:repository_mirrors)
          end)
          expose(*EE::ApplicationSettingsHelper.merge_request_appovers_rules_attributes, if: ->(_instance, _options) do
            ::License.feature_available?(:admin_merge_request_approvers_rules)
          end)
          expose :email_additional_text, if: ->(_instance, _opts) { ::License.feature_available?(:email_additional_text) }
          expose :file_template_project_id, if: ->(_instance, _opts) { ::License.feature_available?(:custom_file_templates) }
          expose :default_project_deletion_protection, if: ->(_instance, _opts) { ::License.feature_available?(:default_project_deletion_protection) }
          expose :deletion_adjourned_period, if: ->(_instance, _opts) { ::License.feature_available?(:adjourned_deletion_for_projects_and_groups) }
          expose :updating_name_disabled_for_users, if: ->(_instance, _opts) { ::License.feature_available?(:disable_name_update_for_users) }
          expose :npm_package_requests_forwarding, if: ->(_instance, _opts) { ::License.feature_available?(:packages) }
        end
      end

      module Todo
        extend ::Gitlab::Utils::Override
        extend ActiveSupport::Concern

        override :todo_target_class
        def todo_target_class(target_type)
          super
        rescue NameError
          # false as second argument prevents looking up in module hierarchy
          # see also https://gitlab.com/gitlab-org/gitlab-foss/issues/59719
          ::EE::API::Entities.const_get(target_type, false)
        end

        override :todo_target_url
        def todo_target_url(todo)
          return super unless todo.target_type == ::DesignManagement::Design.name

          design = todo.target
          path_options = {
            anchor: todo_target_anchor(todo),
            vueroute: design.filename
          }

          ::Gitlab::Routing.url_helpers.designs_project_issue_url(design.project, design.issue, path_options)
        end
      end

      ########################
      # EE-specific entities #
      ########################
      module DesignManagement
        class Design < Grape::Entity
          expose :id
          expose :project_id
          expose :filename
          expose :image_url do |design|
            ::Gitlab::UrlBuilder.build(design)
          end
        end
      end

      class ProjectApprovalRule < ApprovalRule
        expose :protected_branches, using: ::API::Entities::ProtectedBranch, if: -> (rule, _) { rule.project.multiple_approval_rules_available? }
      end

      class MergeRequestApprovalRule < ApprovalRule
        class SourceRule < Grape::Entity
          expose :approvals_required
        end

        expose :source_rule, using: SourceRule
      end

      class MergeRequestApprovalStateRule < MergeRequestApprovalRule
        expose :code_owner
        expose :approved_approvers, as: :approved_by, using: ::API::Entities::UserBasic
        expose :approved?, as: :approved
      end

      class MergeRequestApprovalState < Grape::Entity
        expose :approval_rules_overwritten do |approval_state|
          approval_state.approval_rules_overwritten?
        end

        expose :wrapped_approval_rules, as: :rules, using: MergeRequestApprovalStateRule
      end

      # Being used in private project-level approvals API.
      # This overrides the `eligible_approvers` to be exposed as `approvers`.
      #
      # To be removed in https://gitlab.com/gitlab-org/gitlab/issues/13574.
      class ProjectApprovalSettingRule < ProjectApprovalRule
        expose :approvers, using: ::API::Entities::UserBasic, override: true
      end

      # Being used in private project-level approvals API.
      #
      # To be removed in https://gitlab.com/gitlab-org/gitlab/issues/13574.
      class ProjectApprovalSettings < Grape::Entity
        expose :rules, using: ProjectApprovalSettingRule do |project, options|
          project.visible_approval_rules(target_branch: options[:target_branch])
        end

        expose :min_fallback_approvals, as: :fallback_approvals_required
      end

      # Being used in private MR-level approvals API.
      # This overrides the `eligible_approvers` to be exposed as `approvers`.
      #
      # To be removed in https://gitlab.com/gitlab-org/gitlab/issues/13574.
      class MergeRequestApprovalSettingRule < MergeRequestApprovalStateRule
        expose :approvers, using: ::API::Entities::UserBasic, override: true
      end

      # Being used in private MR-level approvals API.
      # This overrides the `rules` to be exposed using MergeRequestApprovalSettingRule.
      #
      # To be removed in https://gitlab.com/gitlab-org/gitlab/issues/13574.
      class MergeRequestApprovalSettings < MergeRequestApprovalState
        expose :wrapped_approval_rules, as: :rules, using: MergeRequestApprovalSettingRule, override: true
      end

      # @deprecated
      class Approver < Grape::Entity
        expose :user, using: ::API::Entities::UserBasic
      end

      # @deprecated
      class ApproverGroup < Grape::Entity
        expose :group, using: ::API::Entities::Group
      end

      class ApprovalSettings < Grape::Entity
        expose :approvers, using: EE::API::Entities::Approver
        expose :approver_groups, using: EE::API::Entities::ApproverGroup
        expose :approvals_before_merge
        expose :reset_approvals_on_push
        expose :disable_overriding_approvers_per_merge_request
        expose :merge_requests_author_approval
        expose :merge_requests_disable_committers_approval
        expose :require_password_to_approve
      end

      class Approvals < Grape::Entity
        expose :user, using: ::API::Entities::UserBasic
      end

      class ApprovalState < Grape::Entity
        expose :merge_request, merge: true, using: ::API::Entities::IssuableEntity
        expose(:merge_status) { |approval_state| approval_state.merge_request.merge_status }

        expose :approved?, as: :approved

        expose :approvals_required

        expose :approvals_left

        expose :require_password_to_approve do |approval_state|
          approval_state.project.require_password_to_approve?
        end

        expose :approved_by, using: EE::API::Entities::Approvals do |approval_state|
          approval_state.merge_request.approvals
        end

        expose :suggested_approvers, using: ::API::Entities::UserBasic do |approval_state, options|
          approval_state.suggested_approvers(current_user: options[:current_user])
        end

        # @deprecated, reads from first regular rule instead
        expose :approvers do |approval_state|
          if rule = approval_state.first_regular_rule
            rule.users.map do |user|
              { user: ::API::Entities::UserBasic.represent(user) }
            end
          else
            []
          end
        end
        # @deprecated, reads from first regular rule instead
        expose :approver_groups do |approval_state|
          if rule = approval_state.first_regular_rule
            presenter = ::ApprovalRulePresenter.new(rule, current_user: options[:current_user])
            presenter.groups.map do |group|
              { group: ::API::Entities::Group.represent(group) }
            end
          else
            []
          end
        end

        expose :user_has_approved do |approval_state, options|
          approval_state.has_approved?(options[:current_user])
        end

        expose :user_can_approve do |approval_state, options|
          approval_state.can_approve?(options[:current_user])
        end

        expose :approval_rules_left, using: ApprovalRuleShort

        expose :has_approval_rules do |approval_state|
          approval_state.user_defined_rules.present?
        end

        expose :merge_request_approvers_available do |approval_state|
          approval_state.project.feature_available?(:merge_request_approvers)
        end

        expose :multiple_approval_rules_available do |approval_state|
          approval_state.project.multiple_approval_rules_available?
        end
      end

      module ConanPackage
        class ConanPackageManifest < Grape::Entity
          expose :package_urls, merge: true
        end

        class ConanPackageSnapshot < Grape::Entity
          expose :package_snapshot, merge: true
        end

        class ConanRecipeManifest < Grape::Entity
          expose :recipe_urls, merge: true
        end

        class ConanRecipeSnapshot < Grape::Entity
          expose :recipe_snapshot, merge: true
        end

        class ConanUploadUrls < Grape::Entity
          expose :upload_urls, merge: true
        end
      end

      module Nuget
        class ServiceIndex < Grape::Entity
          expose :version
          expose :resources
        end

        class PackageMetadataCatalogEntry < Grape::Entity
          expose :json_url, as: :@id
          expose :authors
          expose :dependencies, as: :dependencyGroups
          expose :package_name, as: :id
          expose :package_version, as: :version
          expose :archive_url, as: :packageContent
          expose :summary
        end

        class PackageMetadata < Grape::Entity
          expose :json_url, as: :@id
          expose :archive_url, as: :packageContent
          expose :catalog_entry, as: :catalogEntry, using: EE::API::Entities::Nuget::PackageMetadataCatalogEntry
        end

        class PackagesMetadataItem < Grape::Entity
          expose :json_url, as: :@id
          expose :lower_version, as: :lower
          expose :upper_version, as: :upper
          expose :packages_count, as: :count
          expose :packages, as: :items, using: EE::API::Entities::Nuget::PackageMetadata
        end

        class PackagesMetadata < Grape::Entity
          expose :count
          expose :items, using: EE::API::Entities::Nuget::PackagesMetadataItem
        end

        class PackagesVersions < Grape::Entity
          expose :versions
        end

        class SearchResultVersion < Grape::Entity
          expose :json_url, as: :@id
          expose :version
          expose :downloads
        end

        class SearchResult < Grape::Entity
          expose :type, as: :@type
          expose :authors
          expose :name, as: :id
          expose :name, as: :title
          expose :summary
          expose :total_downloads, as: :totalDownloads
          expose :verified
          expose :version
          expose :versions, using: EE::API::Entities::Nuget::SearchResultVersion
        end

        class SearchResults < Grape::Entity
          expose :total_count, as: :totalHits
          expose :data, using: EE::API::Entities::Nuget::SearchResult
        end
      end

      class ComposerPackage < Grape::Entity
        expose :name
        expose :versions
      end

      module Analytics
        module CodeReview
          class MergeRequest < ::API::Entities::MergeRequestSimple
            expose :milestone, using: ::API::Entities::Milestone
            expose :author, using: ::API::Entities::UserBasic
            expose :approved_by_users, as: :approved_by, using: ::API::Entities::UserBasic
            expose :notes_count do |mr|
              if options[:issuable_metadata]
                # Avoids an N+1 query when metadata is included
                options[:issuable_metadata][mr.id].user_notes_count
              else
                mr.notes.user.count
              end
            end
            expose :review_time do |mr|
              time = mr.metrics.review_time

              next unless time

              (time / ActiveSupport::Duration::SECONDS_PER_HOUR).floor
            end
            expose :diff_stats

            private

            # rubocop: disable CodeReuse/ActiveRecord
            def diff_stats
              result = {
                additions: object.diffs.diff_files.sum(&:added_lines),
                deletions: object.diffs.diff_files.sum(&:removed_lines),
                commits_count: object.commits_count
              }
              result[:total] = result[:additions] + result[:deletions]
              result
            end
            # rubocop: enable CodeReuse/ActiveRecord
          end
        end
      end

      module UserDetailsWithAdmin
        extend ActiveSupport::Concern

        prepended do
          expose :plan do |user|
            user.namespace.try(:gitlab_subscription)&.plan_name
          end

          expose :trial do |user|
            user.namespace.try(:trial?)
          end
        end
      end
    end
  end
end
