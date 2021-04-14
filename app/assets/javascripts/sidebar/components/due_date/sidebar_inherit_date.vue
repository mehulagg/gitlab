<script>
import { GlFormRadio } from '@gitlab/ui';
import { __ } from '~/locale';
import SidebarFormattedDate from './sidebar_formatted_date.vue';

export default {
  components: {
    GlFormRadio,
    SidebarFormattedDate,
  },
  inject: ['canUpdate'],
  props: {
    formattedDate: {
      required: true,
      type: String,
    },
    hasDate: {
      required: true,
      type: Boolean,
    },
    resetAction: {
      required: true,
      type: Function,
    },
    isLoading: {
      required: true,
      type: Boolean,
    },
  },
  data() {
    return {
      selected: 'inherited',
    };
  },
  i18n: {
    fixed: __('Fixed:'),
    inherited: __('Inherited:'),
    remove: __('remove'),
  },
};
</script>

<template>
  <div class="hide-collapsed">
    <div class="gl-display-flex gl-align-items-baseline">
      <gl-form-radio v-model="selected" value="fixed" :disabled="!canUpdate" class="gl-pr-2">
        {{ $options.i18n.fixed }}
      </gl-form-radio>
      <sidebar-formatted-date
        :has-date="hasDate"
        :formatted-date="formattedDate"
        :reset-action="resetAction"
        :reset-text="$options.i18n.remove"
        :is-loading="isLoading"
        class="gl-line-height-24"
      />
    </div>
    <div class="gl-display-flex gl-align-items-baseline">
      <gl-form-radio v-model="selected" value="inherited" :disabled="!canUpdate" class="gl-pr-2">
        {{ $options.i18n.inherited }}
      </gl-form-radio>
      <sidebar-formatted-date
        :has-date="hasDate"
        :formatted-date="formattedDate"
        :reset-action="resetAction"
        :reset-text="$options.i18n.remove"
        :is-loading="isLoading"
        class="gl-line-height-24"
      />
    </div>
  </div>
</template>
