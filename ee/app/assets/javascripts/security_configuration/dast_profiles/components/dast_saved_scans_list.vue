<script>
import { GlButton } from '@gitlab/ui';
import { redirectTo } from '~/lib/utils/url_utility';
import createFlash from '~/flash';
import { ERROR_RUN_SCAN, ERROR_MESSAGES } from 'ee/on_demand_scans/settings';
import dastProfileRunMutation from '../graphql/dast_profile_run.mutation.graphql';
import ProfilesList from './dast_profiles_list.vue';
import ScanTypeBadge from './dast_scan_type_badge.vue';

export default {
  components: {
    GlButton,
    ProfilesList,
    ScanTypeBadge,
  },
  props: {
    fullPath: {
      type: String,
      required: true,
    },
  },
  methods: {
    async runScan({ id }) {
      try {
        const {
          dastProfileRun: { pipelineUrl, errors },
        } = await this.$apollo.mutate({
          mutation: dastProfileRunMutation,
          variables: {
            input: {
              fullPath: this.fullPath,
              id,
            },
          },
        });

        if (errors.length) {
          this.handleError();
        } else {
          redirectTo(pipelineUrl);
        }
      } catch (error) {
        this.handleError(error);
      }
    },
    handleError(error) {
      createFlash({ message: ERROR_MESSAGES[ERROR_RUN_SCAN], error, captureError: true });
    },
  },
};
</script>

<template>
  <profiles-list :full-path="fullPath" v-bind="$attrs" v-on="$listeners">
    <!-- eslint-disable-next-line vue/valid-v-slot -->
    <template #cell(dastScannerProfile.scanType)="{ value }">
      <scan-type-badge :scan-type="value" />
    </template>

    <template #actions="{ profile }">
      <gl-button size="small" data-testid="dast-scan-run-button" @click="runScan(profile)">{{
        s__('DastProfiles|Run scan')
      }}</gl-button>
    </template>
  </profiles-list>
</template>
