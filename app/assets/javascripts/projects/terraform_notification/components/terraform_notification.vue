<script>
import { GlBanner } from '@gitlab/ui';
import { parseBoolean, setCookie, getCookie } from '~/lib/utils/common_utils';
import { __ } from '~/locale';

export default {
  name: 'TerraformNotification',
  i18n: {
    title: __('Using Terraform? Try the GitLab Managed Terraform State'),
    description: __(
      'The GitLab managed Terraform state backend can store your Terraform state easily and securely, and spares you from setting up additional remote resources. Its features include: versioning, encryption of the state file both in transit and at rest, locking, and remote Terraform plan/apply execution.',
    ),
    buttonText: __("Learn more about GitLab's Backend State"),
  },
  components: {
    GlBanner,
  },
  inject: ['projectId', 'docsUrl'],
  data() {
    return {
      isVisible: true,
    };
  },
  computed: {
    bannerDissmisedKey() {
      return `terraform_notification_dismissed_for_project_${this.projectId}`;
    },
  },
  created() {
    if (parseBoolean(getCookie(this.bannerDissmisedKey))) {
      this.isVisible = false;
    }
  },
  methods: {
    handleClose() {
      setCookie(this.bannerDissmisedKey, true);
      this.isVisible = false;
    },
  },
};
</script>
<template>
  <div v-if="isVisible" class="container-fluid container-limited limit-container-width">
    <div class="gl-py-5">
      <gl-banner
        :title="$options.i18n.title"
        :button-text="$options.i18n.buttonText"
        :button-link="docsUrl"
        variant="introduction"
        @close="handleClose"
      >
        <p>{{ $options.i18n.description }}</p>
      </gl-banner>
    </div>
  </div>
</template>
