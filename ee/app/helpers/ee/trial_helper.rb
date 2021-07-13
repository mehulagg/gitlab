# frozen_string_literal: true

module EE
  module TrialHelper
    def company_size_options_for_select(selected = 0)
      options_for_select([
        [_('Please select'), 0],
        ['1 - 99', '1-99'],
        ['100 - 499', '100-499'],
        ['500 - 1,999', '500-1,999'],
        ['2,000 - 9,999', '2,000-9,999'],
        ['10,000 +', '10,000+']
      ], selected)
    end

    def should_ask_company_question?
      glm_params[:glm_source] != 'about.gitlab.com'
    end

    def glm_params
      strong_memoize(:glm_params) do
        params.slice(:glm_source, :glm_content).to_unsafe_h
      end
    end

    def trial_selection_intro_text
      if any_trial_group_namespaces?
        s_('Trials|You can apply your trial to a new group or an existing group.')
      else
        s_('Trials|Create a new group to start your GitLab Ultimate trial.')
      end
    end

    def show_trial_namespace_select?
      any_trial_group_namespaces?
    end

    def namespace_options_for_select(selected = nil)
      grouped_options = {
        'New' => [[_('Create group'), 0]],
        'Groups' => trial_group_namespaces.map { |n| [n.name, n.id] }
      }

      grouped_options_for_select(grouped_options, selected, prompt: _('Please select'))
    end

    def show_trial_errors?(namespace, service_result)
      namespace&.invalid? || (service_result && !service_result[:success])
    end

    def trial_errors(namespace, service_result)
      namespace&.errors&.full_messages&.to_sentence&.presence || service_result&.dig(:errors)&.presence
    end

    def show_extend_reactivate_trial_button?(namespace)
      return false unless ::Feature.enabled?(:allow_extend_reactivate_trial, namespace, default_enabled: :yaml)

      namespace.can_extend? || namespace.can_reactivate?
    end

    def extend_reactivate_trial_button_data(namespace)
      allow_extend_reactivate_trial_enabled = ::Feature.enabled?(:allow_extend_reactivate_trial, namespace, default_enabled: :yaml)

      action = if allow_extend_reactivate_trial_enabled && namespace.can_extend?
                 'extend'
               elsif allow_extend_reactivate_trial_enabled && namespace.can_reactivate?
                 'reactivate'
               else
                 nil
               end

      {
        namespace_id: namespace.id,
        plan_name: namespace.actual_plan_name.titleize,
        action: action
      }
    end

    private

    def trial_group_namespaces
      strong_memoize(:trial_group_namespaces) do
        current_user.manageable_groups_eligible_for_trial
      end
    end

    def any_trial_group_namespaces?
      trial_group_namespaces.any?
    end
  end
end
