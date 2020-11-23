<script>
import { GlLoadingIcon, GlToggle } from '@gitlab/ui';
import { debounce } from 'lodash';
import { __ } from '~/locale';
import axios from '~/lib/utils/axios_utils';

export default {
  components: {
    GlToggle,
    GlLoadingIcon,
  },
  props: {
    isDisabledAndUnoverridable: {
      type: Boolean,
      required: true,
    },
    isEnabled: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      isLoading: false,
      isSharedRunnerEnabled: false,
      error: null,
    };
  },
  computed: {
  },
  created() {
    this.isSharedRunnerEnabled = this.isEnabled;
  },
  methods: {
    toggleSharedRunners() {
      this.isLoading = true;

      setTimeout(() => {
        this.isSharedRunnerEnabled = !this.isSharedRunnerEnabled;
        this.isLoading = false;
      }, 500) // TODO: integrate backend
    },
  },
};
</script>

<template>
  <div>
    <section
      class="gl-mt-5"
    >
      <h5
        v-if="isDisabledAndUnoverridable"
        class="gl-text-red-500"
        data-testid="shared-runners-disabled-messages"
      >
        {{ __('Shared runners are disabled on group level') }}
      </h5>
      <gl-toggle
        v-else
        :is-loading="isLoading"
        :label="__('Enable shared runners for this project')"
        :value="isSharedRunnerEnabled"
        @change="toggleSharedRunners"
        data-testid="toggle-shared-runners"
      />
    </section>
  </div>
</template>
