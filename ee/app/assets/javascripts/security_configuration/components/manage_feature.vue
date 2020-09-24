<script>
import { GlButton } from '@gitlab/ui';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import CreateMergeRequestButton from './create_merge_request_button.vue';

export default {
  components: {
    GlButton,
    CreateMergeRequestButton,
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
    canConfigureFeature() {
      return Boolean(this.glFeatures.sastConfigurationUi && this.feature.configuration_path);
    },
    // TODO: Remove as part of https://gitlab.com/gitlab-org/gitlab/-/issues/241377
    canCreateSASTMergeRequest() {
      return Boolean(this.feature.type === 'sast' && this.createSastMergeRequestPath);
    },
    canManageProfiles() {
      return this.feature.type === 'dast_profiles';
    },
  },
};
</script>

<template>
  <gl-button
    v-if="canManageProfiles"
    variant="success"
    category="primary"
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

  <gl-button
    v-else-if="canConfigureFeature"
    variant="success"
    category="primary"
    :href="feature.configuration_path"
    data-testid="enableButton"
    >{{ s__('SecurityConfiguration|Enable') }}</gl-button
  >

  <!-- TODO: Remove as part of https://gitlab.com/gitlab-org/gitlab/-/issues/241377 -->
  <create-merge-request-button
    v-else-if="canCreateSASTMergeRequest"
    :auto-devops-enabled="autoDevopsEnabled"
    :endpoint="createSastMergeRequestPath"
  />
</template>
