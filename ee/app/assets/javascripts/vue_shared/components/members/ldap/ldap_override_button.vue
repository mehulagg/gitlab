<script>
import { GlButton, GlTooltipDirective } from '@gitlab/ui';
import { mapActions } from 'vuex';
import { __ } from '~/locale';

export default {
  name: 'LdapOverrideButton',
  i18n: {
    title: __('Edit permissions'),
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
    :title="$options.title"
    :aria-label="$options.title"
    icon="pencil"
    @click="showLdapOverrideConfirmationModal(member)"
  />
</template>
