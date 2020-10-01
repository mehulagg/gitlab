<script>
  import {GlTable} from '@gitlab/ui';
  import { s__} from '~/locale';

  const i18n = {
    title: s__('AlertsIntegrations|Current integrations'),
    emptyState: s__('AlertsIntegrations|No integrations have been added yet'),
    status: {
      enabled: s__('AlertsIntegrations|Enabled'),
      disabled: s__('AlertsIntegrations|Disabled')
    }
  };

  const thClass = 'gl-bg-transparent! gl-border-1! gl-border-b-solid! gl-border-gray-200!';
  const tdClass = 'gl-border-gray-100! gl-p-5!';
  const bodyTrClass =
    'gl-border-1 gl-border-t-solid gl-border-gray-100 gl-hover-bg-blue-50 gl-hover-cursor-pointer gl-border-b-solid gl-hover-border-blue-200';

  export default {
    i18n,
    components:{
      GlTable,
    },
    props: {
      integrations: {
        type: Array,
        required: false,
        default: () => [],
      }
    },
    fields: [
      {
        key: 'status',
        label: s__('AlertsIntegrations|Status'),
        formatter(enabled) {
          return enabled ? i18n.status.enabled : i18n.status.disabled;
        },
        thClass,
        tdClass,
      },
      {
        key: 'name',
        label: s__('AlertsIntegrations|Integration Name'),
        thClass,
        tdClass,
      },
      {
        key: 'type',
        label: s__('AlertsIntegrations|Type'),
        thClass,
        tdClass,
      },
    ],
    computed: {
      tbodyTrClass() {
        return {
          [bodyTrClass]: this.integrations.length,
        };
      },
    }
  };
</script>

<template>
  <div class="incident-management-list">
    <h5>{{$options.i18n.title}}</h5>
    <gl-table
      class="alert-management-details-table"
      :empty-text="$options.i18n.emptyState"
      :items="integrations"
      :fields="$options.fields"
      stacked="md"
      :tbody-tr-class="tbodyTrClass"
      show-empty/>
  </div>
</template>
