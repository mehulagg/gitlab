require 'active_record'

    EXPERIMENTS = {
      onboarding_issues: {
        tracking_category: 'Growth::Conversion::Experiment::OnboardingIssues',
        use_backwards_compatible_subject_index: true
      },
      ci_notification_dot: {
        tracking_category: 'Growth::Expansion::Experiment::CiNotificationDot',
        use_backwards_compatible_subject_index: true
      },
      upgrade_link_in_user_menu_a: {
        tracking_category: 'Growth::Expansion::Experiment::UpgradeLinkInUserMenuA',
        use_backwards_compatible_subject_index: true
      },
      invite_members_version_a: {
        tracking_category: 'Growth::Expansion::Experiment::InviteMembersVersionA',
        use_backwards_compatible_subject_index: true
      },
      invite_members_version_b: {
        tracking_category: 'Growth::Expansion::Experiment::InviteMembersVersionB',
        use_backwards_compatible_subject_index: true
      },
      invite_members_empty_group_version_a: {
        tracking_category: 'Growth::Expansion::Experiment::InviteMembersEmptyGroupVersionA',
        use_backwards_compatible_subject_index: true
      },
      contact_sales_btn_in_app: {
        tracking_category: 'Growth::Conversion::Experiment::ContactSalesInApp',
        use_backwards_compatible_subject_index: true
      },
      customize_homepage: {
        tracking_category: 'Growth::Expansion::Experiment::CustomizeHomepage',
        use_backwards_compatible_subject_index: true
      },
      group_only_trials: {
        tracking_category: 'Growth::Conversion::Experiment::GroupOnlyTrials',
        use_backwards_compatible_subject_index: true
      },
      default_to_issues_board: {
        tracking_category: 'Growth::Conversion::Experiment::DefaultToIssuesBoard',
        use_backwards_compatible_subject_index: true
      },
      jobs_empty_state: {
        tracking_category: 'Growth::Activation::Experiment::JobsEmptyState'
      },
      remove_known_trial_form_fields: {
        tracking_category: 'Growth::Conversion::Experiment::RemoveKnownTrialFormFields'
      },
      trimmed_skip_trial_copy: {
        tracking_category: 'Growth::Conversion::Experiment::TrimmedSkipTrialCopy'
      },
      trial_registration_with_social_signin: {
        tracking_category: 'Growth::Conversion::Experiment::TrialRegistrationWithSocialSigning'
      },
      invite_members_empty_project_version_a: {
        tracking_category: 'Growth::Expansion::Experiment::InviteMembersEmptyProjectVersionA'
      },
      trial_during_signup: {
        tracking_category: 'Growth::Conversion::Experiment::TrialDuringSignup'
      },
      ci_syntax_templates: {
        tracking_category: 'Growth::Activation::Experiment::CiSyntaxTemplates'
      },
      pipelines_empty_state: {
        tracking_category: 'Growth::Activation::Experiment::PipelinesEmptyState'
      },
      invite_members_new_dropdown: {
        tracking_category: 'Growth::Expansion::Experiment::InviteMembersNewDropdown'
      },
      show_trial_status_in_sidebar: {
        tracking_category: 'Growth::Conversion::Experiment::ShowTrialStatusInSidebar'
      },
      trial_onboarding_issues: {
        tracking_category: 'Growth::Conversion::Experiment::TrialOnboardingIssues'
      }
    }.freeze


EXPERIMENTS.each do |key, config|
  classname = "#{key.to_s.camelize}Experiment"
  filename = "#{key}_experiment.rb"

  opts = "\n  TRACKING_CATEGORY = '#{config[:tracking_category]}'"
  if config[:use_backwards_compatible_subject_index]
    opts += "\n  USE_BACKWARDS_COMPATIBLE_SUBJECT_INDEX = true"
  end

code = """# frozen_string_literal: true

class #{classname} < Gitlab::Experimentation::LegacyExperiment#{opts}
end
"""

  File.write("./app/experiments/#{filename}", code)
end
