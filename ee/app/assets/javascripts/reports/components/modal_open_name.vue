<script>
import { GlTooltipDirective, GlResizeObserverDirective } from '@gitlab/ui';
import { mapActions } from 'vuex';
import { VULNERABILITY_MODAL_ID } from 'ee/vue_shared/security_reports/components/constants';
import { BV_SHOW_MODAL } from '~/lib/utils/constants';

export default {
  directives: {
    GlTooltip: GlTooltipDirective,
    GlResizeObserverDirective,
  },
  props: {
    issue: {
      type: Object,
      required: true,
    },
    // failed || success
    status: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      tooltipTitle: '',
    };
  },
  mounted() {
    this.updateTooltipTitle();
  },
  methods: {
    ...mapActions(['setModalData']),
    handleIssueClick() {
      const { issue, status, setModalData } = this;
      setModalData({ issue, status });
      this.$root.$emit(BV_SHOW_MODAL, VULNERABILITY_MODAL_ID);
    },
    updateTooltipTitle() {
      // Only show the tooltip if the text is truncated with an ellipsis.
      this.tooltipTitle = this.$el.offsetWidth < this.$el.scrollWidth ? this.issue.title : '';
    },
  },
};
</script>
<template>
  <button
    v-gl-tooltip="{ boundary: 'viewport' }"
    v-gl-resize-observer-directive="updateTooltipTitle"
    class="btn-link gl-text-truncate"
    :aria-label="s__('Reports|Vulnerability Name')"
    :title="tooltipTitle"
    @click="handleIssueClick()"
  >
    {{ issue.title }}
  </button>
</template>
