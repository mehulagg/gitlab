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
const formatStrategies = {
  environment: env => env?.name,
};
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
];

const formatValueByField = (fieldName, value) => {
  const valueFormatter = formatStrategies[fieldName] || identity;
  return valueFormatter(value);
};

export default {
  components: {
    GlLoadingIcon,
    GlTable,
  },
  inject: {
    glFeatures: {
      default: {},
    },
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
    flaggedAllowedFields() {
      return this.shouldDisplayEnvironment ? [...allowedFields, 'environment'] : allowedFields;
    },
    items() {
      if (!this.alert) {
        return [];
      }
      return reduce(
        this.alert,
        (allowedItems, rawValue, fieldName) => {
          if (this.isAllowed(fieldName)) {
            const value = formatValueByField(fieldName, rawValue);
            return [...allowedItems, { fieldName, value }];
          }
          return allowedItems;
        },
        [],
      );
    },
    shouldDisplayEnvironment() {
      return this.glFeatures.enableEnvironmentPathInAlertDetails;
    },
  },
  methods: {
    isAllowed(fieldName) {
      return this.flaggedAllowedFields.includes(fieldName);
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
