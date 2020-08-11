<script>
import { GlToggle, GlLoadingIcon } from '@gitlab/ui';
import { debounce } from 'lodash';
import { __ } from '~/locale';
import createFlash from '~/flash';
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
    updatePayload() {
      return {
        shared_runners_enabled: this.enabled,
        ...(this.enabled
          ? {}
          : { allow_descendants_override_disabled_shared_runners: this.allowOverride }),
      };
    },
  },
  created() {
    this.onToggleChange = debounce(this.onToggleChangeRaw.bind(this), DEBOUNCE_TOGGLE_DELAY);
  },
  methods: {
    onToggleChangeRaw() {
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

          createFlash(message);
        });
    },
  },
};
</script>

<template>
  <div>
    <h4 class="gl-display-flex gl-align-items-center">
      {{ __('Set up Shared Runner availability') }}
      <gl-loading-icon v-show="isLoading" class="gl-ml-3" inline />
    </h4>

    <section class="gl-mt-5">
      <gl-toggle
        v-model="enabled"
        :disabled="toggleDisabled"
        :label="__('Enable Shared Runners for this group')"
        @change="onToggleChange"
      />

      <span class="text-muted">
        {{
          __(
            'Enables Shared Runners for existing and new projects/subgroups that belong to this group.',
          )
        }}
      </span>
    </section>

    <section v-if="!enabled" class="gl-mt-5">
      <gl-toggle
        v-model="allowOverride"
        :disabled="toggleDisabled"
        :label="__('Allow projects/subgroups to override the group setting')"
        @change="onToggleChange"
      />

      <span class="text-muted">
        {{
          __(
            'Allows projects or subgroups that belong to this group to override the global setting and use Shared Runners on an opt-in basis.',
          )
        }}
      </span>
    </section>
  </div>
</template>
