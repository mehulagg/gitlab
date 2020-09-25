<script>
import { GlToggle, GlLoadingIcon, GlTooltip } from '@gitlab/ui';
import { debounce } from 'lodash';
import { __ } from '~/locale';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { DEBOUNCE_TOGGLE_DELAY, ERROR_MESSAGE } from '../constants';

export default {
  enabledSetting: 'enabled',
  disabledSetting: 'disabled_and_unoverridable',
  allowOverrideSetting: 'disabled_with_override',
  components: {
    GlToggle,
    GlLoadingIcon,
    GlTooltip,
  },
  props: {
    updatePath: {
      type: String,
      required: true,
    },
    initEnabled: {
      type: Boolean,
      required: true,
    },
    initAllowOverride: {
      type: Boolean,
      required: true,
    },
    parentAllowOverride: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      enabled: this.initEnabled,
      allowOverride: this.initAllowOverride,
      isLoading: false,
    };
  },
  computed: {
    toggleDisabled() {
      return !this.parentAllowOverride || this.isLoading;
    },
    enabledOrDisabledSetting() {
      return this.enabled ? this.$options.enabledSetting : this.$options.disabledSetting;
    },
    disabledWithOverrideSetting() {
      return this.allowOverride
        ? this.$options.allowOverrideSetting
        : this.$options.disabledSetting;
    },
  },
  methods: {
    enableOrDisable() {
      this.updateRunnerSettings({
        shared_runners_setting: this.enabledOrDisabledSetting,
      });

      // reset override toggle to false if shared runners are enabled
      this.allowOverride = false;
    },
    override() {
      this.updateRunnerSettings({
        shared_runners_setting: this.disabledWithOverrideSetting,
      });
    },
    updateRunnerSettings: debounce(function debouncedUpdateRunnerSettings(setting) {
      this.isLoading = true;

      axios
        .post(this.updatePath, setting)
        .then(() => {
          this.isLoading = false;
        })
        .catch(error => {
          const message = [
            error.response?.data?.error || __('An error occurred while updating configuration.'),
            ERROR_MESSAGE,
          ].join(' ');

          createFlash(message);
        });
    }, DEBOUNCE_TOGGLE_DELAY),
  },
};
</script>

<template>
  <div ref="sharedRunnersForm">
    <h4 class="gl-display-flex gl-align-items-center">
      {{ __('Set up shared runner availability') }}
      <gl-loading-icon v-show="isLoading" class="gl-ml-3" inline />
    </h4>

    <section class="gl-mt-5">
      <gl-toggle
        v-model="enabled"
        :disabled="toggleDisabled"
        :label="__('Enable shared runners for this group')"
        data-testid="enable-runners-toggle"
        @change="enableOrDisable"
      />

      <span class="text-muted">
        {{
          __(
            'Enables shared runners for existing and new projects/subgroups that belong to this group.',
          )
        }}
      </span>
    </section>

    <section v-if="!enabled" class="gl-mt-5">
      <gl-toggle
        v-model="allowOverride"
        :disabled="toggleDisabled"
        :label="__('Allow projects/subgroups to override the group setting')"
        data-testid="override-runners-toggle"
        @change="override"
      />

      <span class="text-muted">
        {{
          __(
            'Allows projects or subgroups that belong to this group to override the global setting and use shared runners on an opt-in basis.',
          )
        }}
      </span>
    </section>

    <gl-tooltip v-if="toggleDisabled" :target="() => $refs.sharedRunnersForm">
      {{ __('Shared runners disabled on group level') }}
    </gl-tooltip>
  </div>
</template>
