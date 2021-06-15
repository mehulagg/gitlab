<script>
import { GlButton, GlModalDirective, GlTooltipDirective as GlTooltip } from '@gitlab/ui';
import { __, s__, sprintf } from '~/locale';
import timeagoMixin from '~/vue_shared/mixins/timeago';
import DeleteEnvironmentModal from './delete_environment_modal.vue';
import StopEnvironmentModal from './stop_environment_modal.vue';

export default {
  name: 'EnvironmentsDetailHeader',
  components: {
    GlButton,
    DeleteEnvironmentModal,
    StopEnvironmentModal,
  },
  directives: {
    GlModalDirective,
    GlTooltip,
  },
  mixins: [timeagoMixin],
  props: {
    environment: {
      type: Object,
      required: true,
    },
    canReadEnvironment: {
      type: Boolean,
      required: true,
    },
    canAdminEnvironment: {
      type: Boolean,
      required: true,
    },
    canUpdateEnvironment: {
      type: Boolean,
      required: true,
    },
    canDestroyEnvironment: {
      type: Boolean,
      required: true,
    },
    canStopEnvironment: {
      type: Boolean,
      required: true,
    },
    cancelAutoStopPath: {
      type: String,
      required: false,
      default: '',
    },
    metricsPath: {
      type: String,
      required: false,
      default: '',
    },
    updatePath: {
      type: String,
      required: false,
      default: '',
    },
    terminalPath: {
      type: String,
      required: false,
      default: '',
    },
  },
  i18n: {
    metricsButtonTitle: __('See metrics'),
    metricsButtonText: __('Monitoring'),
    editButtonText: __('Edit'),
    stopButtonText: s__('Environments|Stop'),
    deleteButtonText: s__('Environments|Delete'),
    externalButtonTitle: s__('Environments|Open live environment'),
    externalButtonText: __('View deployment'),
    cancelAutoStopButtonTitle: __('Prevent environment from auto-stopping'),
  },
  computed: {
    autoStopAt() {
      return sprintf(s__('Environments|Auto stops %{autoStopAt}'), {
        autoStopAt: this.timeFormatted(this.environment.autoStopAt),
      });
    },
    shouldShowCancelAutoStopButton() {
      return this.environment.isAvailable && Boolean(this.environment.autoStopAt);
    },
    shouldShowExternalUrlButton() {
      return this.canReadEnvironment && Boolean(this.environment.externalUrl);
    },
    shouldShowStopButton() {
      return this.canStopEnvironment && this.environment.isAvailable;
    },
    shouldShowTerminalButton() {
      return this.canAdminEnvironment && this.environment.hasTerminals;
    },
  },
};
</script>
<template>
  <header class="top-area gl-justify-content-between">
    <div class="gl-display-flex gl-flex-grow-1 gl-align-items-center">
      <h3 class="page-title">
        {{ environment.name }}
      </h3>
      <p v-if="environment.autoStopAt" class="gl-mb-0 gl-ml-3">
        {{ autoStopAt }}
      </p>
    </div>
    <div class="nav-controls gl-my-1">
      <gl-button
        v-if="shouldShowCancelAutoStopButton"
        v-gl-tooltip.hover
        :href="cancelAutoStopPath"
        :title="$options.i18n.cancelAutoStopButtonTitle"
        icon="thumbtack"
      />
      <gl-button v-if="shouldShowTerminalButton" :href="terminalPath" icon="terminal" />
      <gl-button
        v-if="shouldShowExternalUrlButton"
        v-gl-tooltip.hover
        :title="$options.i18n.externalButtonTitle"
        :href="environment.externaUrl"
        icon="external-link"
        >{{ $options.i18n.externalButtonText }}</gl-button
      >
      <gl-button
        v-if="canReadEnvironment"
        :href="metricsPath"
        :title="$options.i18n.metricsButtonTitle"
        icon="chart"
        class="gl-mr-2"
      >
        {{ $options.i18n.metricsButtonText }}
      </gl-button>
      <gl-button v-if="canUpdateEnvironment" :href="updatePath">
        {{ $options.i18n.editButtonText }}
      </gl-button>
      <gl-button
        v-if="shouldShowStopButton"
        v-gl-modal-directive="'stop-environment-modal'"
        icon="stop"
        variant="danger"
      >
        {{ $options.i18n.stopButtonText }}
      </gl-button>
      <gl-button
        v-if="canDestroyEnvironment"
        v-gl-modal-directive="'delete-environment-modal'"
        variant="danger"
      >
        {{ $options.i18n.deleteButtonText }}
      </gl-button>
    </div>
    <delete-environment-modal v-if="canDestroyEnvironment" :environment="environment" />
    <stop-environment-modal v-if="shouldShowStopButton" :environment="environment" />
  </header>
</template>
