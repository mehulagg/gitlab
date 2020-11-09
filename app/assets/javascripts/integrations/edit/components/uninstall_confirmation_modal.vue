<script>
import { mapGetters } from 'vuex';
import { GlFormGroup, GlFormRadio, GlModal } from '@gitlab/ui';

import { uninstallOptions } from '../constants';
import { __ } from '~/locale';

export default {
  components: {
    GlFormGroup,
    GlFormRadio,
    GlModal,
  },
  data() {
    return {
      uninstallAll: false,
    };
  },
  computed: {
    ...mapGetters(['isDisabled']),
    primaryProps() {
      return {
        text: __('Uninstall'),
        attributes: [{ variant: 'danger' }, { category: 'primary' }, { disabled: this.isDisabled }],
      };
    },
    cancelProps() {
      return {
        text: __('Cancel'),
      };
    },
  },
  methods: {
    onUninstall() {
      this.$emit('uninstall', this.uninstallAll);
    },
  },
  uninstallOptions,
};
</script>

<template>
  <gl-modal
    modal-id="confirmUninstallIntegration"
    size="sm"
    :title="s__('Integrations|Uninstall integration?')"
    :action-primary="primaryProps"
    :action-cancel="cancelProps"
    @primary="onUninstall"
  >
    <p>
      {{ s__('Integrations|Some projects are using these settings as the default.') }}
      <br />
      {{ s__('Integrations|How do you want to apply the changes to these projects?') }}
    </p>

    <gl-form-group>
      <gl-form-radio
        v-for="uninstallOption in $options.uninstallOptions"
        :key="uninstallOption.value"
        v-model="uninstallAll"
        :value="uninstallOption.value"
      >
        {{ uninstallOption.label }}
        <template #help>
          {{ uninstallOption.help }}
        </template>
      </gl-form-radio>
    </gl-form-group>

    <p class="gl-mb-0">
      {{ s__('Integrations|Projects using custom settings will not be impacted.') }}
    </p>
  </gl-modal>
</template>
