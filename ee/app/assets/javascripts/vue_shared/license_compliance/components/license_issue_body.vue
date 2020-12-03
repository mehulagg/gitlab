<script>
import { mapActions } from 'vuex';
import { GlLink } from '@gitlab/ui';

import { LICENSE_MANAGEMENT } from 'ee/vue_shared/license_compliance/store/constants';
import LicensePackages from './license_packages.vue';

export default {
  name: 'LicenseIssueBody',
  components: { LicensePackages, GlLink },
  props: {
    issue: {
      type: Object,
      required: true,
    },
  },
  methods: { ...mapActions(LICENSE_MANAGEMENT, ['setLicenseInModal']) },
};
</script>

<template>
  <div class="report-block-info license-item">
    <gl-link :href="issue.url" target="_blank">{{ issue.name }}</gl-link>
    <license-packages :packages="issue.packages" class="text-secondary" />
  </div>
</template>
