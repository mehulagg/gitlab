<script>
import { GlEmptyState } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  components: {
    GlEmptyState,
  },
  props: {
    imagePath: {
      type: String,
      required: true,
    },
  },
  i18n: {
    heading: __('There are no compliance framework labels set up yet'),
    description: __('Once you have created a compliance framework label it will appear here.'),
    addButton: __('Add framework'),
  },
};
</script>

<template>
  <gl-empty-state
    :title="$options.i18n.heading"
    :description="$options.i18n.description"
    :svg-path="imagePath"
    primary-button-link="#"
    :primary-button-text="$options.i18n.addButton"
    compact
    class="gl-mt-5"
  />
</template>
