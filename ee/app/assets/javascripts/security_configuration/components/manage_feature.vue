<script>
import { GlButton } from '@gitlab/ui';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';

export default {
  components: {
    GlButton,
  },
  mixins: [glFeatureFlagsMixin()],
  props: {
    feature: {
      type: Object,
      required: true,
    },
    autoDevopsEnabled: {
      type: Boolean,
      required: true,
    },
    createSastMergeRequestPath: {
      type: String,
      required: true,
    },
  },
  computed: {
    canManageProfiles() {
      return this.feature.type === 'dast_profiles';
    },
  },
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
    v-else-if="feature.configured"
    :href="feature.configuration_path"
    data-testid="configureButton"
    >{{ s__('SecurityConfiguration|Configure') }}</gl-button
  >

  <gl-button
    v-else
    variant="success"
    category="primary"
    :href="feature.configuration_path"
    data-testid="enableButton"
    >{{ s__('SecurityConfiguration|Enable') }}</gl-button
  >
</template>
