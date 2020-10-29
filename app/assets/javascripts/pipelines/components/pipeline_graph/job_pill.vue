<script>
import tooltipOnTruncate from '~/vue_shared/components/tooltip_on_truncate.vue';

export default {
  jobRef: 'JOB_REF',
  emptyLinksAdditionalWidth: 12,
  components: {
    tooltipOnTruncate,
  },
  props: {
    jobName: {
      type: String,
      required: true,
    },
    jobId: {
      type: String,
      required: true,
    },
    isHighlighted: {
      type: Boolean,
      required: false,
      default: false,
    },
    isFadedOut: {
      type: Boolean,
      required: false,
      default: false,
    },
    handleMouseOver: {
      type: Function,
      required: false,
      default: () => {},
    },
    handleMouseLeave: {
      type: Function,
      required: false,
      default: () => {},
    },
    hasNoLinks: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      offsetWidth: 0,
    };
  },
  computed: {
    jobPillClasses() {
      return [
        { 'gl-opacity-3': this.isFadedOut },
        this.isHighlighted ? 'gl-shadow-blue-200-x0-y0-b4-s2' : 'gl-inset-border-2-green-400',
      ];
    },
    emptyLinksWidth() {
      return this.offsetWidth + this.$options.emptyLinksAdditionalWidth;
    },
    emptyLinksLeftPosition() {
      return this.$options.emptyLinksAdditionalWidth / 2;
    },
    cutoffStyle() {
      // We use the width of the pill and then add a value that serves as padding and
      // we then move the start of the element halfway to have the same width each side.
      /* eslint-disable @gitlab/require-i18n-strings */
      return `width: ${this.emptyLinksWidth}px; left: -${this.emptyLinksLeftPosition}px;`;
    },
    showCutoffLine() {
      // When a job has no links, we add a div the same color as the background
      // to visually cut off the links to avoid confusing user that the nodes
      // are connected when they actually aren't. We also don't cut off the link
      // when there is a hover because we want the line to go through the pills.
      return this.hasNoLinks && !this.isFadedOut;
    },
  },
  mounted() {
    this.offsetWidth = this.$refs[this.$options.jobRef].offsetWidth;
  },
  methods: {
    onMouseEnter() {
      this.$emit('on-mouse-enter', this.jobId);
    },
    onMouseLeave() {
      this.$emit('on-mouse-leave');
    },
  },
};
</script>
<template>
  <tooltip-on-truncate :title="jobName" truncate-target="child" placement="top">
    <div class="gl-relative">
      <div
        v-if="showCutoffLine"
        class="gl-absolute gl-bg-gray-50 gl-min-h-6"
        :style="cutoffStyle"
      ></div>
      <div
        :id="jobId"
        :ref="$options.jobRef"
        class="pipeline-job-pill gl-bg-white gl-text-center gl-text-truncate gl-rounded-pill gl-mb-3 gl-px-5 gl-py-2 gl-relative gl-z-index-1 gl-transition-duration-slow gl-transition-timing-function-ease"
        :class="jobPillClasses"
        @mouseover="onMouseEnter"
        @mouseleave="onMouseLeave"
      >
        {{ jobName }}
      </div>
    </div>
  </tooltip-on-truncate>
</template>
