<script>
import { GlButton, GlIcon, GlFormInput } from '@gitlab/ui';
import Select2Select from '~/vue_shared/components/select2_select.vue';
import { __ } from '~/locale';
import ImportStatus from '../../components/import_status.vue';

export default {
  components: {
    Select2Select,
    ImportStatus,
    GlButton,
    GlIcon,
    GlFormInput,
  },
  props: {
    group: {
      type: Object,
      required: true,
    },
    availableNamespaces: {
      type: Array,
      required: true,
    },
  },
  computed: {
    select2Options() {
      return {
        data: this.availableNamespaces.map(namespace => ({
          id: namespace.full_path,
          text: namespace.full_path,
        })),
        containerCssClass: '',
      };
    },
  },
};
</script>

<template>
  <tr>
    <td>
      <a :href="group.web_url" rel="noreferrer noopener" target="_blank">
        {{ group.full_path }} <gl-icon name="external-link" />
      </a>
    </td>
    <td class="d-flex flex-wrap flex-lg-nowrap">
      <select2-select
        :options="select2Options"
        :value="group.import_target.target_namespace || availableNamespaces[0].full_path"
        @input="$emit('update-target-namespace', $event)"
      />
      <span class="px-2">
        /
      </span>
      <gl-form-input
        type="text"
        :value="group.import_target.new_name"
        @input="$emit('update-new-name', $event)"
      />
    </td>
    <td>
      <import-status :status="group.status" />
    </td>
    <td>
      <gl-button variant="success" category="secondary">{{ __('Import') }}</gl-button>
    </td>
  </tr>
</template>
