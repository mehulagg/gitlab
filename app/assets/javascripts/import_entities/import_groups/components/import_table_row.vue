<script>
import { GlButton, GlIcon, GlFormInput } from '@gitlab/ui';
import Select2Select from '~/vue_shared/components/select2_select.vue';
import ImportStatus from '../../components/import_status.vue';
import { STATUSES } from '../../constants';

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
      };
    },
  },
  STATUSES,
};
</script>

<template>
  <tr class="gl-border-gray-200 gl-border-0 gl-border-b-1">
    <td class="gl-p-4">
      <a :href="group.web_url" rel="noreferrer noopener" target="_blank">
        {{ group.full_path }} <gl-icon name="external-link" />
      </a>
    </td>
    <td class="gl-p-4">
      <div class="import-entities-target-select gl-display-flex gl-align-items-stretch">
        <select2-select
          :options="select2Options"
          :value="group.import_target.target_namespace"
          @input="$emit('update-target-namespace', $event)"
        />
        <div
          class="gl-px-3 gl-display-flex gl-align-items-center gl-border-solid gl-border-gray-200 gl-border-0 gl-border-t-1 gl-border-b-1"
        >
          /
        </div>
        <gl-form-input
          class="gl-rounded-top-left-none gl-rounded-bottom-left-none"
          :value="group.import_target.new_name"
          @input="$emit('update-new-name', $event)"
        />
      </div>
    </td>
    <td class="gl-p-4 gl-white-space-nowrap">
      <import-status :status="group.status" />
    </td>
    <td class="gl-p-4">
      <gl-button
        v-if="group.status === $options.STATUSES.NONE"
        variant="success"
        category="secondary"
        @click="$emit('import-group')"
        >{{ __('Import') }}</gl-button
      >
    </td>
  </tr>
</template>
