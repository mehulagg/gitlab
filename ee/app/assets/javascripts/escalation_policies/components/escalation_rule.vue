<script>
import {
  GlFormGroup,
  GlFormInput,
  GlDropdown,
  GlDropdownItem,
  GlCard,
  GlIcon,
  GlSprintf,
  GlTooltipDirective as GlTooltip,
} from '@gitlab/ui';
import { s__ } from '~/locale';
import { ACTIONS, ALERT_STATUSES } from '../constants';

export const i18n = {
  fields: {
    rules: {
      condition: s__('EscalationPolicies|IF alert is not %{alertStatus} in %{minutes} minutes'),
      action: s__('EscalationPolicies|THEN %{doAction} %{schedule}'),
      selectSchedule: s__('EscalationPolicies|Select schedule'),
      validationMsg: s__(
        'EscalationPolicies|A schedule is required for adding an escalation policy.',
      ),
      noSchedules: s__(
        'EscalationPolicies|A schedule is required for adding an escalation policy. Please create an on-call schedule first.',
      ),
    },
  },
};

export default {
  i18n,
  ALERT_STATUSES,
  ACTIONS,
  components: {
    GlFormGroup,
    GlFormInput,
    GlDropdown,
    GlDropdownItem,
    GlCard,
    GlIcon,
    GlSprintf,
  },
  directives: {
    GlTooltip,
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
    schedulesLoading: {
      type: Boolean,
      required: true,
      default: true,
    },
    index: {
      type: Number,
      required: true,
    },
    isValid: {
      type: Boolean,
      required: false,
      default: true,
    },
  },
  data() {
    const { status, elapsedTimeSeconds, action, oncallScheduleIid } = this.rule;
    return {
      status,
      elapsedTimeSeconds,
      action,
      oncallScheduleIid,
    };
  },
  computed: {
    scheduleDropdownTitle() {
      return this.oncallScheduleIid
        ? this.schedules.find(({ iid }) => iid === this.oncallScheduleIid)?.name
        : i18n.fields.rules.selectSchedule;
    },
    noSchedules() {
      return !this.schedulesLoading && !this.schedules.length;
    },
  },
  methods: {
    setOncallSchedule({ iid }) {
      this.oncallScheduleIid = this.oncallScheduleIid === iid ? null : iid;
      this.emitUpdate();
    },
    setStatus(status) {
      this.status = status;
      this.emitUpdate();
    },
    emitUpdate() {
      this.$emit('update-escalation-rule', this.index, {
        oncallScheduleIid: parseInt(this.oncallScheduleIid, 10),
        action: this.action,
        status: this.status,
        elapsedTimeSeconds: parseInt(this.elapsedTimeSeconds, 10),
      });
    },
  },
};
</script>

<template>
  <gl-card class="gl-border-gray-400 gl-bg-gray-10 gl-mb-3 gl-relative">
    <gl-icon
      v-if="index !== 0"
      name="close"
      class="gl-absolute rule-close-icon"
      @click="$emit('remove-escalation-rule', index)"
    />
    <gl-form-group
      :invalid-feedback="$options.i18n.fields.rules.validationMsg"
      :state="isValid"
      class="gl-mb-0"
    >
      <div class="gl-display-flex gl-align-items-center">
        <gl-sprintf :message="$options.i18n.fields.rules.condition">
          <template #alertStatus>
            <gl-dropdown
              class="rule-control gl-mx-3"
              :text="$options.ALERT_STATUSES[status]"
              data-testid="alert-status-dropdown"
            >
              <gl-dropdown-item
                v-for="(label, alertStatus) in $options.ALERT_STATUSES"
                :key="alertStatus"
                :is-checked="status === alertStatus"
                is-check-item
                @click="setStatus(alertStatus)"
              >
                {{ label }}
              </gl-dropdown-item>
            </gl-dropdown>
          </template>
          <template #minutes>
            <gl-form-input
              v-model="elapsedTimeSeconds"
              class="gl-mx-3 gl-inset-border-1-gray-200! rule-elapsed-minutes"
              type="number"
              min="0"
              @change="emitUpdate"
            />
          </template>
        </gl-sprintf>
      </div>
      <div class="gl-display-flex gl-align-items-center gl-mt-3">
        <gl-sprintf :message="$options.i18n.fields.rules.action">
          <template #doAction>
            <gl-dropdown
              class="rule-control gl-mx-3"
              :text="$options.ACTIONS[rule.action]"
              data-testid="action-dropdown"
            >
              <gl-dropdown-item
                v-for="(label, ruleAction) in $options.ACTIONS"
                :key="ruleAction"
                :is-checked="rule.action === ruleAction"
                is-check-item
              >
                {{ label }}
              </gl-dropdown-item>
            </gl-dropdown>
          </template>
          <template #schedule>
            <gl-dropdown
              :disabled="noSchedules"
              class="rule-control"
              :text="scheduleDropdownTitle"
              data-testid="schedules-dropdown"
            >
              <template #button-text>
                <span :class="{ 'gl-text-gray-400': !oncallScheduleIid }">
                  {{ scheduleDropdownTitle }}
                </span>
              </template>
              <gl-dropdown-item
                v-for="schedule in schedules"
                :key="schedule.iid"
                :is-checked="schedule.iid === oncallScheduleIid"
                is-check-item
                @click="setOncallSchedule(schedule)"
              >
                {{ schedule.name }}
              </gl-dropdown-item>
            </gl-dropdown>
            <gl-icon
              v-if="noSchedules"
              v-gl-tooltip
              :title="$options.i18n.fields.rules.noSchedules"
              name="information-o"
              class="gl-text-gray-500 gl-ml-3"
              data-testid="no-schedules-info-icon"
            />
          </template>
        </gl-sprintf>
      </div>
    </gl-form-group>
  </gl-card>
</template>
