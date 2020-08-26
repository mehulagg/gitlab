<script>
import { GlButton, GlLink } from '@gitlab/ui';
import { sprintf, s__ } from '~/locale';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import CreateMergeRequestButton from './create_merge_request_button.vue';

export default {
  components: {
    GlButton,
    GlLink,
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
    gitlabCiPresent: {
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
      return Boolean(
        this.glFeatures.sastConfigurationUi &&
          this.feature.configuration_path &&
          !this.gitlabCiPresent,
      );
    },
    // TODO: Remove as part of https://gitlab.com/gitlab-org/gitlab/-/issues/227575
    canCreateSASTMergeRequest() {
      return Boolean(
        this.feature.type === 'sast' && this.createSastMergeRequestPath && !this.gitlabCiPresent,
      );
    },
    getFeatureDocumentationLinkLabel() {
      return sprintf(s__('SecurityConfiguration|Feature documentation for %{featureName}'), {
        featureName: this.feature.name,
      });
    },
  },

  emits: [],
};
</script>

<template>
  <gl-button
    v-if="canConfigureFeature && autoDevopsEnabled"
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

  <!-- TODO: Remove as part of https://gitlab.com/gitlab-org/gitlab/-/issues/227575 -->
  <create-merge-request-button
    v-else-if="canCreateSASTMergeRequest"
    :auto-devops-enabled="autoDevopsEnabled"
    :endpoint="createSastMergeRequestPath"
  />

  <gl-link
    v-else
    target="_blank"
    :href="feature.link"
    :aria-label="getFeatureDocumentationLinkLabel"
    data-testid="docsLink"
  >
    {{ s__('SecurityConfiguration|See documentation') }}
  </gl-link>
</template>
