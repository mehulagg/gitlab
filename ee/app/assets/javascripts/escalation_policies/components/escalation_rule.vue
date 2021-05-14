<script>
import {
  GlFormInput,
  GlDropdown,
  GlDropdownItem,
  GlSafeHtmlDirective as SafeHtml,
  GlCard,
} from '@gitlab/ui';
import { s__, __ } from '~/locale';
import { ACTIONS, ALERT_STATUSES } from '../constants';

export const i18n = {
  fields: {
    rules: {
      title: s__('EscalationPolicies|Escalation rules'),
      ifNot: s__('EscalationPolicies|IF alert is not'),
      in: __('in'),
      minutes: __('minutes'),
      then: __('THEN'),
      selectSchedule: s__('EscalationPolicies|Select schedule'),
    },
  },
};

export default {
  i18n,
  ALERT_STATUSES,
  ACTIONS,
  components: {
    GlFormInput,
    GlDropdown,
    GlDropdownItem,
    GlCard,
  },
  directives: {
    SafeHtml,
  },
  props: {
    rule: {
      type: Object,
      required: true,
    },
    schedules: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
};
</script>

<template>
  <gl-card class="gl-border-gray-400 gl-bg-gray-10 gl-mb-3">
    <div class="gl-display-flex gl-align-items-center">
      <span>{{ $options.i18n.fields.rules.ifNot }}</span>
      <gl-dropdown class="rule-control gl-mx-3" :text="$options.ALERT_STATUSES[rule.status]">
        <gl-dropdown-item
          v-for="(label, status) in $options.ALERT_STATUSES"
          :key="status"
          :is-checked="rule.status === status"
          is-check-item
        >
          {{ label }}
        </gl-dropdown-item>
      </gl-dropdown>
      <span>{{ $options.i18n.fields.rules.in }}</span>
      <gl-form-input class="gl-mx-3 rule-elapsed-minutes" :value="0" />
      <span>{{ $options.i18n.fields.rules.minutes }}</span>
    </div>

    <div class="gl-display-flex gl-align-items-center gl-mt-3">
      <span class="gl-text-gray-700">{{ $options.i18n.fields.rules.then }}</span>
      <gl-dropdown class="rule-control gl-mx-3" :text="$options.ACTIONS[rule.action]">
        <gl-dropdown-item
          v-for="(label, action) in $options.ACTIONS"
          :key="action"
          :is-checked="rule.action === action"
          is-check-item
        >
          {{ label }}
        </gl-dropdown-item>
      </gl-dropdown>

      <gl-dropdown class="rule-control gl-mx-3" :text="$options.i18n.fields.rules.selectSchedule">
        <gl-dropdown-item v-for="schedule in schedules" :key="schedule.id" is-check-item>
          {{ schedule.name }}
        </gl-dropdown-item>
      </gl-dropdown>
    </div>
  </gl-card>
</template>
