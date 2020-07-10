<script>
/* global Flash */

import { GlToggle, GlLoadingIcon } from '@gitlab/ui';
import { debounce } from 'lodash';
import { __ } from '~/locale';
import axios from '~/lib/utils/axios_utils';
import { DEBOUNCE_TOGGLE_DELAY, ERROR_MESSAGE } from '../constants';

export default {
  components: {
    GlToggle,
    GlLoadingIcon,
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
    parentEnabled: {
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
    allowOverrideToggleDisabled() {
      return this.enabled || !this.parentAllowOverride || this.isLoading;
    },
    disabled: {
      get() {
        return !this.enabled;
      },
      set(val) {
        this.enabled = !val;
      },
    },
    updatePayload() {
      return {
        shared_runners_enabled: this.enabled,
        ...(this.enabled
          ? {}
          : { allow_descendants_override_disabled_shared_runners: this.allowOverride }),
      };
    },
  },
  methods: {
    onToggleChange: debounce(function toggleChange() {
      this.isLoading = true;

      axios
        .post(this.updatePath, this.updatePayload)
        .then(() => {
          this.isLoading = false;
        })
        .catch(error => {
          const message = [
            error.response?.data?.error || __('An error occurred while updating configuration.'),
            ERROR_MESSAGE,
          ].join(' ');

          Flash(message);

          throw error;
        });
    }, DEBOUNCE_TOGGLE_DELAY),
  },
};
</script>

<template>
  <div>
    <h4 class="gl-display-flex gl-align-items-center">
      {{ __('Set up shared Runner availability') }}
      <gl-loading-icon v-show="isLoading" class="gl-ml-3" inline />
    </h4>

    <section class="gl-mt-5">
      <gl-toggle
        v-model="disabled"
        :disabled="toggleDisabled"
        :label="__('Disable Shared Runners for this group')"
        @change="onToggleChange"
      />

      <span class="text-muted" data-testid="description-span">
        {{
          __(
            'Disables Shared Runners for existing and new projects/subgroups that belong to this group.',
          )
        }}
      </span>
    </section>

    <section class="gl-mt-5">
      <gl-toggle
        v-model="allowOverride"
        :disabled="allowOverrideToggleDisabled"
        :label="__('Allow projects/subgroups to override the group setting')"
        @change="onToggleChange"
      />

      <span class="text-muted" data-testid="description-span">
        {{
          __(
            'Allows projects or subgroups that belong to this group to override the global setting and use Shared Runners on an opt-in basis.',
          )
        }}
      </span>
    </section>
  </div>
</template>
