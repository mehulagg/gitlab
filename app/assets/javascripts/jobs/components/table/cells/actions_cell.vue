<script>
import { GlButton } from '@gitlab/ui';
import { i18n } from '../constants';

export default {
  components: {
    GlButton,
  },
  props: {
    job: {
      type: Object,
      required: true,
    },
  },
  computed: {
    i18n() {
      return i18n;
    },
    active() {
      return this.job.active;
    },
    manualJobPlayable() {
      // TODO: Do the admin checks
      return this.job.playable && this.job.manualJob;
    },
    retryable() {
      return this.job.retryable;
    },
    scheduled() {
      return this.job.scheduled;
    },
  },
};
</script>

<template>
  <div class="gl-display-flex">
    <gl-button icon="download" :title="i18n.downloadArtifacts" />
    <gl-button v-if="active" icon="close" :title="i18n.cancel" />
    <template v-if="scheduled">
      <!--TODO: Delayed jobs might need their own component as a modal is needed-->
      <gl-button icon="planning" />
      <gl-button icon="play" :title="i18n.startNow" />
      <gl-button icon="time-out" :title="i18n.unschedule" />
    </template>
    <!--Note: This is the manual job play button -->
    <gl-button v-if="manualJobPlayable" icon="play" :title="i18n.play" />
    <gl-button v-if="retryable" icon="repeat" :title="i18n.retry" />
  </div>
</template>
