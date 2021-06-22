<script>
import { GlEmptyState, GlModalDirective } from '@gitlab/ui';
import { DEVOPS_ADOPTION_STRINGS } from '../constants';

export default {
  name: 'DevopsAdoptionEmptyState',
  components: {
    GlEmptyState,
  },
  directives: {
    GlModal: GlModalDirective,
  },
  inject: ['emptyStateSvgPath'],
  i18n: DEVOPS_ADOPTION_STRINGS.emptyState,
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
