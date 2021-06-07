<script>
import {
  GlModalDirective,
  GlTooltipDirective,
  GlButton,
  GlButtonGroup,
  GlCard,
  GlSprintf,
  GlIcon,
  GlCollapse,
} from '@gitlab/ui';
import { s__ } from '~/locale';
import { ACTIONS, ALERT_STATUSES, DEFAULT_ACTION } from '../constants';

export const i18n = {
  editPolicy: s__('EscalationPolicies|Edit escalation policy'),
  deletePolicy: s__('EscalationPolicies|Delete escalation policy'),
  escalationRule: s__(
    'EscalationPolicies|IF alert is not %{alertStatus} in %{minutes} %{then} THEN %{doAction} %{schedule}',
  ),
  minutes: s__('EscalationPolicies|mins'),
};

export default {
  i18n,
  ACTIONS,
  ALERT_STATUSES,
  DEFAULT_ACTION,
  components: {
    GlButton,
    GlButtonGroup,
    GlCard,
    GlSprintf,
    GlIcon,
    GlCollapse,
  },
  directives: {
    GlModal: GlModalDirective,
    GlTooltip: GlTooltipDirective,
  },
  props: {
    policy: {
      type: Object,
      required: true,
    },
    index: {
      type: Number,
      required: true,
    },
  },
  data() {
    return {
      isPolicyVisible: this.index === 0,
    };
  },
  computed: {
    policyVisibleAngleIcon() {
      return this.isPolicyVisible ? 'angle-down' : 'angle-right';
    },
  },
};
</script>

<template>
  <div>
    <gl-card class="gl-mt-5" header-class="gl-py-3">
      <template #header>
        <div
          class="gl-display-flex gl-justify-content-space-between gl-align-items-center gl-m-0"
          data-testid="policy-header"
        >
          <div class="gl-font-weight-bold gl-font-lg">
            <gl-icon
              v-gl-tooltip
              class="gl-hover-cursor-pointer gl-mr-2"
              :aria-label="policyVisibleAngleIcon"
              :size="12"
              :name="policyVisibleAngleIcon"
              @click="isPolicyVisible = !isPolicyVisible"
            />
            <span> {{ policy.name }}</span>
          </div>
          <gl-button-group>
            <gl-button
              v-gl-tooltip
              :title="$options.i18n.editPolicy"
              icon="pencil"
              :aria-label="$options.i18n.editPolicy"
              disabled
            />
            <gl-button
              v-gl-tooltip
              :title="$options.i18n.deletePolicy"
              icon="remove"
              :aria-label="$options.i18n.deletePolicy"
              disabled
            />
          </gl-button-group>
        </div>
      </template>
      <gl-collapse :visible="isPolicyVisible">
        <p
          v-if="policy.description"
          class="gl-text-gray-500 gl-mb-5"
          data-testid="policy-description"
        >
          {{ policy.description }}
        </p>
        <div class="gl-border-solid gl-border-1 gl-border-gray-100 gl-rounded-small gl-p-5">
          <div
            v-for="(rule, ruleIndex) in policy.rules"
            :key="rule.id"
            class="gl-text-gray-900"
            :class="{ 'gl-mb-5': ruleIndex !== policy.rules.length - 1 }"
          >
            <gl-icon name="clock" class="gl-mr-3" />
            <gl-sprintf :message="$options.i18n.escalationRule">
              <template #alertStatus>
                {{ $options.ALERT_STATUSES[rule.status].toLowerCase() }}
              </template>
              <template #minutes>
                <span class="gl-font-weight-bold">
                  {{ rule.elapsedTimeSeconds }} {{ $options.i18n.minutes }}
                </span>
              </template>
              <template #then>
                <div class="right-arrow">
                  <i class="right-arrow-head"></i>
                </div>
                <gl-icon name="notifications" class="gl-mr-3" />
              </template>
              <template #doAction>
                {{ $options.ACTIONS[$options.DEFAULT_ACTION].toLowerCase() }}
              </template>
              <template #schedule>
                <span class="gl-font-weight-bold">
                  {{ rule.oncallSchedule.name }}
                </span>
              </template>
            </gl-sprintf>
          </div>
        </div>
      </gl-collapse>
    </gl-card>
  </div>
</template>
