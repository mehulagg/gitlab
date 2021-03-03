<script>
import { GlEmptyState, GlButton, GlModalDirective } from '@gitlab/ui';
import { DEVOPS_ADOPTION_STRINGS, DEVOPS_ADOPTION_SEGMENT_MODAL_ID } from '../constants';

export default {
  name: 'DevopsAdoptionEmptyState',
  components: {
    GlEmptyState,
    GlButton,
  },
  directives: {
    GlModal: GlModalDirective,
  },
  inject: ['emptyStateSvgPath'],
  i18n: DEVOPS_ADOPTION_STRINGS.emptyState,
  devopsSegmentModalId: DEVOPS_ADOPTION_SEGMENT_MODAL_ID,
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
  >
    <template #actions>
      <gl-button
        v-gl-modal="$options.devopsSegmentModalId"
        :disabled="!hasGroupsData"
        variant="info"
        @click="$emit('clear-selected-segment')"
        >{{ $options.i18n.button }}</gl-button
      >
    </template>
  </gl-empty-state>
</template>
