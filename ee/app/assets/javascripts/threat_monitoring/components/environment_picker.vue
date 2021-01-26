<script>
import { mapActions, mapGetters, mapState } from 'vuex';
import { GlFormGroup, GlDeprecatedDropdown, GlDeprecatedDropdownItem } from '@gitlab/ui';
import { ALL_ENVIRONMENT_NAME } from '../constants';

export default {
  components: {
    GlFormGroup,
    GlDeprecatedDropdown,
    GlDeprecatedDropdownItem,
  },
  props: {
    includeAll: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    ...mapState('threatMonitoring', ['environments', 'currentEnvironmentId', 'allEnvironments']),
    ...mapGetters('threatMonitoring', ['currentEnvironmentName', 'canChangeEnvironment']),
    environmentName() {
      return this.allEnvironments && this.includeAll
        ? ALL_ENVIRONMENT_NAME
        : this.currentEnvironmentName;
    },
  },
  methods: {
    ...mapActions('threatMonitoring', ['setCurrentEnvironmentId', 'setAllEnvironments']),
  },
  environmentFilterId: 'threat-monitoring-environment-filter',
  ALL_ENVIRONMENT_NAME,
};
</script>

<template>
  <gl-form-group
    :label="s__('ThreatMonitoring|Environment')"
    label-size="sm"
    :label-for="$options.environmentFilterId"
    class="col-sm-6 col-md-4 col-lg-3 col-xl-2"
  >
    <gl-deprecated-dropdown
      :id="$options.environmentFilterId"
      ref="environmentsDropdown"
      class="mb-0 d-flex"
      toggle-class="d-flex justify-content-between text-truncate"
      :text="environmentName"
      :disabled="!canChangeEnvironment"
    >
      <gl-deprecated-dropdown-item
        v-for="environment in environments"
        :key="environment.id"
        ref="environmentsDropdownItem"
        @click="setCurrentEnvironmentId(environment.id)"
        >{{ environment.name }}</gl-deprecated-dropdown-item
      >
      <gl-deprecated-dropdown-item
        v-if="includeAll"
        ref="environmentsDropdownItem"
        @click="setAllEnvironments"
        >{{ $options.ALL_ENVIRONMENT_NAME }}</gl-deprecated-dropdown-item
      >
    </gl-deprecated-dropdown>
  </gl-form-group>
</template>
