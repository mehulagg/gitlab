<script>
import SettingsBlock from '~/vue_shared/components/settings/settings_block.vue';

import { PACKAGE_SETTINGS_HEADER, PACKAGE_SETTINGS_DESCRIPTION } from '../constants';

export default {
  name: 'GroupSettingsApp',
  i18n: {
    PACKAGE_SETTINGS_HEADER,
    PACKAGE_SETTINGS_DESCRIPTION,
  },
  components: {
    SettingsBlock,
  },
  inject: {
    defaultExpanded: {
      type: Boolean,
      default: false,
      required: true,
    },
  },
};
</script>

<template>
  <div>
    <settings-block :default-expanded="defaultExpanded">
      <template #title> {{ $options.i18n.PACKAGE_SETTINGS_HEADER }}</template>
      <template #description>
        {{ $options.i18n.PACKAGE_SETTINGS_DESCRIPTION }}
      </template>
    </settings-block>
  </div>
</template>
