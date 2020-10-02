<script>
/**
 * Renders the delete button that allows deleting a stopped environment.
 * Used in the environments table and the environment detail view.
 */

import $ from 'jquery';
import { GlTooltipDirective, GlButton } from '@gitlab/ui';
import Icon from '~/vue_shared/components/icon.vue';
import { s__ } from '~/locale';
import eventHub from '../event_hub';

export default {
  components: {
    Icon,
    GlButton,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    environment: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      isLoading: false,
    };
  },
  computed: {
    title() {
      return s__('Environments|Delete environment');
    },
  },
  mounted() {
    eventHub.$on('deleteEnvironment', this.onDeleteEnvironment);
  },
  beforeDestroy() {
    eventHub.$off('deleteEnvironment', this.onDeleteEnvironment);
  },
  methods: {
    onClick() {
      $(this.$el).tooltip('dispose');
      eventHub.$emit('requestDeleteEnvironment', this.environment);
    },
    onDeleteEnvironment(environment) {
      if (this.environment.id === environment.id) {
        this.isLoading = true;
      }
    },
  },
};
</script>
<template>
  <gl-button
    v-gl-tooltip
    :loading="isLoading"
    :title="title"
    :aria-label="title"
    class="d-none d-sm-none d-md-block"
    variant = "danger"
    category = "primary"
    icon = "remove"
    data-toggle="modal"
    data-target="#delete-environment-modal"
    @click="onClick"
  />
</template>
