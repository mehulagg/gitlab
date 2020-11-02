<script>
import { GlButton, GlTooltipDirective } from '@gitlab/ui';
import { mapActions } from 'vuex';
import { s__ } from '~/locale';

export default {
  name: 'LdapOverrideButton',
  i18n: {
    title: s__('Members|Edit permissions'),
  },
  components: { GlButton },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    member: {
      type: Object,
      required: true,
    },
  },
  methods: {
    ...mapActions(['showLdapOverrideConfirmationModal']),
  },
};
</script>

<template>
  <gl-button
    v-gl-tooltip.hover
    :title="$options.i18n.title"
    :aria-label="$options.i18n.title"
    icon="pencil"
    @click="showLdapOverrideConfirmationModal(member)"
  />
</template>
