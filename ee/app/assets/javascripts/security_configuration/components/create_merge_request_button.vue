<script>
import { GlButton } from '@gitlab/ui';
import * as Sentry from '~/sentry/wrapper';
import axios from '~/lib/utils/axios_utils';
import { s__ } from '~/locale';
import { redirectTo } from '~/lib/utils/url_utility';
import { deprecatedCreateFlash as createFlash } from '~/flash';

export default {
  components: {
    GlButton,
  },
  props: {
    autoDevopsEnabled: {
      type: Boolean,
      required: true,
    },
    endpoint: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      isCreatingMergeRequest: false,
    };
  },
  computed: {
    buttonProps() {
      if (this.autoDevopsEnabled) {
        return {
          text: this.$options.i18n.autoDevOps,
        };
      }

      return {
        text: this.$options.i18n.noAutoDevOps,
        category: 'primary',
        variant: 'success',
      };
    },
  },
  methods: {
    createMergeRequest() {
      this.isCreatingMergeRequest = true;

      return axios
        .post(this.endpoint)
        .then(({ data }) => {
          const { filePath } = data;
          if (!filePath) {
            // eslint-disable-next-line @gitlab/require-i18n-strings
            throw new Error('SAST merge request creation failed');
          }

          redirectTo(filePath);
        })
        .catch((error) => {
          this.isCreatingMergeRequest = false;
          createFlash(
            s__('SecurityConfiguration|An error occurred while creating the merge request.'),
          );
          Sentry.captureException(error);
        });
    },
  },
  i18n: {
    autoDevOps: s__('SecurityConfiguration|Configure'),
    noAutoDevOps: s__('SecurityConfiguration|Enable via Merge Request'),
  },
};
</script>

<template>
  <gl-button :loading="isCreatingMergeRequest" v-bind="buttonProps" @click="createMergeRequest">{{
    buttonProps.text
  }}</gl-button>
</template>
