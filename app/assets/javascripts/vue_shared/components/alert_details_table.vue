<script>
import { GlLoadingIcon, GlTable } from '@gitlab/ui';
import { identity, reduce } from 'lodash';
import { s__ } from '~/locale';
import {
  capitalizeFirstCharacter,
  convertToSentenceCase,
  splitCamelCase,
} from '~/lib/utils/text_utility';

const thClass = 'gl-bg-transparent! gl-border-1! gl-border-b-solid! gl-border-gray-200!';
const tdClass = 'gl-border-gray-100! gl-p-5!';
const allowedFields = [
  'iid',
  'title',
  'severity',
  'status',
  'startedAt',
  'eventCount',
  'monitoringTool',
  'service',
  'description',
  'endedAt',
  'details',
  'environment',
];
const formatStrategies = {
  environment: env => env?.name,
};

const isAllowed = fieldName => allowedFields.includes(fieldName);
const getFormatStrategy = field => formatStrategies[field] || identity;

export default {
  components: {
    GlLoadingIcon,
    GlTable,
  },
  props: {
    alert: {
      type: Object,
      required: false,
      default: null,
    },
    loading: {
      type: Boolean,
      required: true,
    },
  },
  fields: [
    {
      key: 'fieldName',
      label: s__('AlertManagement|Key'),
      thClass,
      tdClass,
      formatter: string => capitalizeFirstCharacter(convertToSentenceCase(splitCamelCase(string))),
    },
    {
      key: 'value',
      thClass: `${thClass} w-60p`,
      tdClass,
      label: s__('AlertManagement|Value'),
    },
  ],
  computed: {
    items() {
      if (!this.alert) {
        return [];
      }
      return reduce(
        this.alert,
        (allowedItems, rawValue, fieldName) => {
          if (isAllowed(fieldName)) {
            const formatValue = getFormatStrategy(fieldName);
            return [...allowedItems, { fieldName, value: formatValue(rawValue) }];
          }
          return allowedItems;
        },
        [],
      );
    },
  },
};
</script>
<template>
  <gl-table
    class="alert-management-details-table"
    :busy="loading"
    :empty-text="s__('AlertManagement|No alert data to display.')"
    :items="items"
    :fields="$options.fields"
    show-empty
  >
    <template #table-busy>
      <gl-loading-icon size="lg" color="dark" class="gl-mt-5" />
    </template>
  </gl-table>
</template>
