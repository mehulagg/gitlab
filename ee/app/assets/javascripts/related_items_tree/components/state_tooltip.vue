<script>
import { GlTooltip } from '@gitlab/ui';

import { formatDate } from '~/lib/utils/datetime_utility';
import { __ } from '~/locale';
import timeagoMixin from '~/vue_shared/mixins/timeago';

export default {
  components: {
    GlTooltip,
  },
  mixins: [timeagoMixin],
  props: {
    getTargetRef: {
      type: Function,
      required: true,
    },
    path: {
      type: String,
      required: true,
    },
    isOpen: {
      type: Boolean,
      required: true,
    },
    state: {
      type: String,
      required: true,
    },
    createdAt: {
      type: String,
      required: true,
    },
    closedAt: {
      type: String,
      required: true,
    },
  },
  computed: {
    stateText() {
      return this.isOpen ? __('Created') : __('Closed');
    },
    createdAtInWords() {
      return this.getTimestampInWords(this.createdAt);
    },
    closedAtInWords() {
      return this.getTimestampInWords(this.closedAt);
    },
    createdAtTimestamp() {
      return this.getTimestamp(this.createdAt);
    },
    closedAtTimestamp() {
      return this.getTimestamp(this.closedAt);
    },
    stateTimeInWords() {
      return this.isOpen ? this.createdAtInWords : this.closedAtInWords;
    },
    stateTimestamp() {
      return this.isOpen ? this.createdAtTimestamp : this.closedAtTimestamp;
    },
  },
  methods: {
    getTimestamp(rawTimestamp) {
      return rawTimestamp ? formatDate(new Date(rawTimestamp)) : '';
    },
    getTimestampInWords(rawTimestamp) {
      return rawTimestamp ? this.timeFormatted(rawTimestamp) : '';
    },
  },
};
</script>

<template>
  <gl-tooltip :target="getTargetRef()">
    <div ref="statePath" class="bold">
      {{ path }}
    </div>
    <div class="text-tertiary">
      <span ref="stateText" class="bold">
        {{ stateText }}
      </span>
      {{ stateTimeInWords }}
      <div ref="stateTimestamp">{{ stateTimestamp }}</div>
    </div>
  </gl-tooltip>
</template>
