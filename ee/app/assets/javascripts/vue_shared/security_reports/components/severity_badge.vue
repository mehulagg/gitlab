<script>
import { GlIcon, GlTooltipDirective } from '@gitlab/ui';
import { SEVERITY_LEVELS } from 'ee/security_dashboard/store/constants';
import { SEVERITY_CLASS_NAME_MAP, SEVERITY_TOOLTIP_TITLE_MAP } from './constants';

export default {
  name: 'SeverityBadge',
  components: {
    GlIcon,
  },
  directives: {
    tooltip: GlTooltipDirective,
  },
  props: {
    severity: {
      type: String,
      required: true,
    },
  },
  computed: {
    hasSeverityBadge() {
      return Object.keys(SEVERITY_CLASS_NAME_MAP).includes(this.severityKey);
    },
    severityKey() {
      return this.severity?.toLowerCase();
    },
    className() {
      return SEVERITY_CLASS_NAME_MAP[this.severityKey];
    },
    iconName() {
      return `severity-${this.severityKey}`;
    },
    severityTitle() {
      return SEVERITY_LEVELS[this.severityKey] || this.severity;
    },
    tooltipTitle() {
      return SEVERITY_TOOLTIP_TITLE_MAP[this.severityKey];
    },
  },
};
</script>

<template>
  <div v-if="hasSeverityBadge" class="severity-badge text-sm-left text-nowrap gl-text-gray-900">
    <span :class="className"
      ><gl-icon v-tooltip="tooltipTitle" :name="iconName" :size="12" class="gl-mr-3"
    /></span>
    {{ severityTitle }}
  </div>
</template>
