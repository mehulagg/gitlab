<script>
import { GlButton } from '@gitlab/ui';
import EnableFeatureViaMr from './enable_feature_via_mr.vue';

export default {
  components: {
    GlButton,
    EnableFeatureViaMr
  },
  props: {
    feature: {
      type: Object,
      required: true,
    },
    autoDevopsEnabled: {
      type: Boolean,
      required: true,
    },
  },
  computed: {
    canConfigureFeature() {
      return Boolean(this.feature.configuration_path);
    },
    canManageProfiles() {
      return this.feature.type === 'dast_profiles';
    },
  }
};
</script>

<template>
  <gl-button
    v-if="canManageProfiles"
    :href="feature.configuration_path"
    data-testid="manageButton"
    >{{ s__('SecurityConfiguration|Manage') }}</gl-button
  >

  <gl-button
    v-else-if="canConfigureFeature && feature.configured"
    :href="feature.configuration_path"
    data-testid="configureButton"
    >{{ s__('SecurityConfiguration|Configure') }}</gl-button
  >
  
  <enable-feature-via-mr v-else-if="feature.type === 'dependency_scanning'" :feature="feature.type"></enable-feature-via-mr>

  <gl-button
    v-else-if="canConfigureFeature"
    variant="success"
    category="primary"
    :href="feature.configuration_path"
    data-testid="enableButton"
    >{{ s__('SecurityConfiguration|Enable') }}</gl-button
  >
  

</template>
