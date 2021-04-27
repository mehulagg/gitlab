<script>
import { GlTable } from '@gitlab/ui';
import { __ } from '~/locale';

const DEFAULT_TH_CLASSES =
  'gl-bg-transparent! gl-border-b-solid! gl-border-b-gray-100! gl-p-5! gl-border-b-1!';
const thWidthClass = (width) => `gl-w-${width}p ${DEFAULT_TH_CLASSES}`;

export default {
  components: {
    GlTable,
  },
  fields: [
    {
      key: 'name',
      label: __('Service name'),
      thClass: thWidthClass(20),
    },
    {
      key: 'api',
      label: __('API'),
      thClass: thWidthClass(35),
    },
    {
      key: 'branch',
      label: __('Target branch'),
      thClass: thWidthClass(30),
    },
    {
      key: 'actions',
      label: '',
      thClass: thWidthClass(15),
    }
  ],
};
</script>

<template>
  <gl-table
    :items="[]"
    :fields="$options.fields"
    :empty-text="s__('StatusCheck|No status checks are defined yet.')"
    show-empty
    stacked="md"
  />
</template>
