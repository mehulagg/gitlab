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
  GlToken,
  GlAvatar,
} from '@gitlab/ui';
import { s__, __ } from '~/locale';
import {
  ACTIONS,
  ALERT_STATUSES,
  EMAIL_ONCALL_SCHEDULE_USER,
  deleteEscalationPolicyModalId,
  editEscalationPolicyModalId,
  EMAIL_USER,
} from '../constants';
import EditEscalationPolicyModal from './add_edit_escalation_policy_modal.vue';
import DeleteEscalationPolicyModal from './delete_escalation_policy_modal.vue';

const BASE_ARROW_LENGTH = 40; // px

export const i18n = {
  editPolicy: s__('EscalationPolicies|Edit escalation policy'),
  deletePolicy: s__('EscalationPolicies|Delete escalation policy'),
  escalationRuleCondition: s__(
    'EscalationPolicies|%{clockIcon} IF alert is not %{alertStatus} in %{minutes}',
  ),
  escalationRuleAction: s__(
    'EscalationPolicies|%{notificationIcon} THEN %{doAction} %{forScheduleOrUser}',
  ),
  minutes: s__('EscalationPolicies|mins'),
};

const isRuleValid = ({ status, elapsedTimeMinutes, oncallSchedule, user }) =>
  Object.keys(ALERT_STATUSES).includes(status) &&
  typeof elapsedTimeMinutes === 'number' &&
  (typeof oncallSchedule?.name === 'string' || typeof user?.username === 'string');

export default {
  i18n,
  ACTIONS,
  ALERT_STATUSES,
  EMAIL_ONCALL_SCHEDULE_USER,
  components: {
    GlButton,
    GlButtonGroup,
    GlCard,
    GlSprintf,
    GlIcon,
    GlCollapse,
    GlToken,
    GlAvatar,
    DeleteEscalationPolicyModal,
    EditEscalationPolicyModal,
  },
  directives: {
    GlModal: GlModalDirective,
    GlTooltip: GlTooltipDirective,
  },
  props: {
    policy: {
      type: Object,
      required: true,
      validator: ({ name, rules }) => {
        return typeof name === 'string' && Array.isArray(rules) && rules.every(isRuleValid);
      },
    },
    index: {
      type: Number,
      required: true,
    },
  },
  data() {
    return {
      isPolicyVisible: this.index === 0,
      ruleContainerWidth: 0,
    };
  },
  computed: {
    baseArrowLength() {
      if (this.ruleContainerWidth) {
        const halfContainerSize = this.ruleContainerWidth / 2;
        const maxRules = 10;
        const baseArrowLength = halfContainerSize / maxRules;
        return baseArrowLength > BASE_ARROW_LENGTH ? BASE_ARROW_LENGTH : baseArrowLength;
      }
      return BASE_ARROW_LENGTH;
    },
    policyVisibleAngleIcon() {
      return this.isPolicyVisible ? 'angle-down' : 'angle-right';
    },
    policyVisibleAngleIconLabel() {
      return this.isPolicyVisible ? __('Collapse') : __('Expand');
    },
    editPolicyModalId() {
      return `${editEscalationPolicyModalId}-${this.policy.id}`;
    },
    deletePolicyModalId() {
      return `${deleteEscalationPolicyModalId}-${this.policy.id}`;
    },
  },
  mounted() {
    this.ruleContainerWidth = this.$refs.ruleContainer?.clientWidth;
  },
  methods: {
    hasEscalationSchedule(rule) {
      return rule.oncallSchedule?.iid;
    },
    hasEscalationUser(rule) {
      return rule.user?.username;
    },
    getActionName(rule) {
      return (this.hasEscalationSchedule(rule)
        ? ACTIONS[EMAIL_ONCALL_SCHEDULE_USER]
        : ACTIONS[EMAIL_USER]
      ).toLowerCase();
    },
    getArrowLength(index) {
      const length = (index + 1) * this.baseArrowLength;
      return `${length}px`;
    },
  },
};
</script>

<template>
  <div>
    <gl-card
      class="gl-mt-5"
      :class="{ 'gl-border-bottom-0': !isPolicyVisible }"
      :body-class="{ 'gl-p-0': !isPolicyVisible }"
      :header-class="{ 'gl-py-3': true, 'gl-rounded-base': !isPolicyVisible }"
    >
      <template #header>
        <div class="gl-display-flex gl-align-items-center">
          <gl-button
            v-gl-tooltip
            class="gl-mr-2 gl-p-0!"
            :title="policyVisibleAngleIconLabel"
            :aria-label="policyVisibleAngleIconLabel"
            category="tertiary"
            @click="isPolicyVisible = !isPolicyVisible"
          >
            <gl-icon :size="12" :name="policyVisibleAngleIcon" />
          </gl-button>

          <h3 class="gl-font-weight-bold gl-font-lg gl-m-0">{{ policy.name }}</h3>
          <gl-button-group class="gl-ml-auto">
            <gl-button
              v-gl-modal="editPolicyModalId"
              v-gl-tooltip
              :title="$options.i18n.editPolicy"
              icon="pencil"
              :aria-label="$options.i18n.editPolicy"
            />
            <gl-button
              v-gl-modal="deletePolicyModalId"
              v-gl-tooltip
              :title="$options.i18n.deletePolicy"
              :aria-label="$options.i18n.deletePolicy"
              icon="remove"
            />
          </gl-button-group>
        </div>
      </template>
      <gl-collapse :visible="isPolicyVisible">
        <p v-if="policy.description" class="gl-text-gray-500 gl-mb-5">
          {{ policy.description }}
        </p>
        <div
          ref="ruleContainer"
          class="gl-border-solid gl-border-1 gl-border-gray-100 gl-rounded-base gl-p-5"
        >
          <div
            v-for="(rule, ruleIndex) in policy.rules"
            :key="rule.id"
            :class="{ 'gl-mb-5': ruleIndex !== policy.rules.length - 1 }"
            class="gl-display-flex gl-align-items-center gl-flex-wrap"
          >
            <span class="rule-condition">
              <gl-sprintf :message="$options.i18n.escalationRuleCondition">
                <template #clockIcon>
                  <gl-icon name="clock" class="gl-mr-3" />
                </template>
                <template #alertStatus>
                  {{ $options.ALERT_STATUSES[rule.status].toLowerCase() }}
                </template>
                <template #minutes>
                  <span class="gl-font-weight-bold">
                    {{ rule.elapsedTimeMinutes }} {{ $options.i18n.minutes }}
                  </span>
                </template>
              </gl-sprintf>
            </span>
            <span class="right-arrow" :style="{ width: getArrowLength(ruleIndex) }">
              <i class="right-arrow-head"></i>
            </span>

            <span>
              <gl-sprintf :message="$options.i18n.escalationRuleAction">
                <template #notificationIcon>
                  <gl-icon name="notifications" class="gl-mr-3" />
                </template>
                <template #doAction>
                  {{ getActionName(rule) }}
                </template>
                <template #forScheduleOrUser>
                  <span v-if="hasEscalationSchedule(rule)" class="gl-font-weight-bold">
                    {{ rule.oncallSchedule.name }}
                  </span>
                  <gl-token v-else-if="hasEscalationUser(rule)" view-only>
                    <gl-avatar :src="rule.user.avatarUrl" :size="16" />
                    {{ rule.user.name }}
                  </gl-token>
                </template>
              </gl-sprintf>
            </span>
          </div>
        </div>
      </gl-collapse>
    </gl-card>

    <delete-escalation-policy-modal :escalation-policy="policy" :modal-id="deletePolicyModalId" />
    <edit-escalation-policy-modal
      :escalation-policy="policy"
      :modal-id="editPolicyModalId"
      is-edit-mode
    />
  </div>
</template>
