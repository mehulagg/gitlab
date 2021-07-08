<script>
import { GlEmptyState, GlModalDirective } from '@gitlab/ui';
import { DA_EMPTY_STATE_TITLE, DA_EMPTY_STATE_DESCRIPTION } from '../constants';

export default {
  name: 'DevopsAdoptionEmptyState',
  components: {
    GlEmptyState,
  },
  directives: {
    GlModal: GlModalDirective,
  },
  inject: ['emptyStateSvgPath'],
  i18n: {
    title: DA_EMPTY_STATE_TITLE,
    description: DA_EMPTY_STATE_DESCRIPTION,
  },
  props: {
    hasGroupsData: {
      type: Boolean,
      required: true,
    },
  },
};
</script>
<template>
  <gl-empty-state
    :title="$options.i18n.title"
    :description="$options.i18n.description"
    :svg-path="emptyStateSvgPath"
  />
</template>
