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
      selectSchedule: s__('EscalationPolicies|-- Select schedule --'),
      selectStatus: s__('EscalationPolicies|-- Select status --'),
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
    index: {
      type: Number,
      required: true,
    },
  },
  data() {
    const { oncallScheduleId, status, elapsedTimeSeconds } = this.rule;
    return {
      oncallScheduleId,
      status,
      elapsedTimeSeconds,
    };
  },
  computed: {
    scheduleDropdownTitle() {
      return this.oncallScheduleId
        ? this.schedules.find(({ iid }) => iid === this.oncallScheduleId)?.name
        : i18n.fields.rules.selectSchedule;
    },
    statusDropdownTitle() {
      return this.status ? ALERT_STATUSES[this.status] : i18n.fields.rules.selectStatus;
    },
  },
  methods: {
    setOncallSchedule({ iid }) {
      this.oncallScheduleId = this.oncallScheduleId === iid ? null : iid;
      this.emitUpdate();
    },
    setStatus(status) {
      this.status = this.status === status ? null : status;
      this.emitUpdate();
    },
    emitUpdate() {
      this.$emit('update-escalation-rule', this.index, {
        oncallScheduleId: parseInt(this.oncallScheduleId, 10),
        status: this.status,
        elapsedTimeSeconds: parseInt(this.elapsedTimeSeconds, 10),
      });
    },
  },
};
</script>

<template>
  <gl-card class="gl-border-gray-400 gl-bg-gray-10 gl-mb-3">
    <div class="gl-display-flex gl-align-items-center">
      <span>{{ $options.i18n.fields.rules.ifNot }}</span>
      <gl-dropdown class="rule-control gl-mx-3" :text="statusDropdownTitle">
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
      <span>{{ $options.i18n.fields.rules.in }}</span>
      <gl-form-input
        v-model="elapsedTimeSeconds"
        class="gl-mx-3 rule-elapsed-minutes"
        type="number"
        @change="emitUpdate"
      />
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

      <gl-dropdown class="rule-control gl-mx-3" :text="scheduleDropdownTitle">
        <gl-dropdown-item
          v-for="schedule in schedules"
          :key="schedule.iid"
          :is-checked="schedule.iid === oncallScheduleId"
          is-check-item
          @click="setOncallSchedule(schedule)"
        >
          {{ schedule.name }}
        </gl-dropdown-item>
      </gl-dropdown>
    </div>
  </gl-card>
</template>
