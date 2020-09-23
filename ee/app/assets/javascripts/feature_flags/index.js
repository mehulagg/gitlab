import Vue from 'vue';
import FeatureFlagsComponent from 'ee/feature_flags/components/feature_flags.vue';
import csrf from '~/lib/utils/csrf';

export default () =>
  new Vue({
    el: '#feature-flags-vue',
    components: {
      FeatureFlagsComponent,
    },
    data() {
      return {
        dataset: document.querySelector(this.$options.el).dataset,
      };
    },
    provide() {
      return {
        projectName: this.dataset.projectName,
      };
    },
    render(createElement) {
      return createElement('feature-flags-component', {
        props: {
          endpoint: this.dataset.endpoint,
          projectId: this.dataset.projectId,
          errorStateSvgPath: this.dataset.errorStateSvgPath,
          featureFlagsHelpPagePath: this.dataset.featureFlagsHelpPagePath,
          featureFlagsClientLibrariesHelpPagePath: this.dataset
            .featureFlagsClientLibrariesHelpPagePath,
          featureFlagsClientExampleHelpPagePath: this.dataset.featureFlagsClientExampleHelpPagePath,
          unleashApiUrl: this.dataset.unleashApiUrl,
          unleashApiInstanceId: this.dataset.unleashApiInstanceId || '',
          csrfToken: csrf.token,
          canUserConfigure: this.dataset.canUserAdminFeatureFlag,
          newFeatureFlagPath: this.dataset.newFeatureFlagPath,
          rotateInstanceIdPath: this.dataset.rotateInstanceIdPath,
          newUserListPath: this.dataset.newUserListPath,
        },
      });
    },
  });
