<script>
import { mapActions } from 'vuex';
import { GlButton, GlTooltipDirective } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  name: 'RemoveGroupLinkButton',
  buttonTitle: s__('Members|Remove group'),
  components: { GlButton },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    groupLink: {
      type: Object,
      required: true,
    },
  },
  methods: {
    ...mapActions(['showRemoveGroupLinkModal']),
  },
};
</script>

<template>
  <gl-button
    v-gl-tooltip.hover
    variant="danger"
    :title="$options.buttonTitle"
    :aria-label="$options.buttonTitle"
    icon="remove"
    @click="showRemoveGroupLinkModal(groupLink)"
  />
</template>
