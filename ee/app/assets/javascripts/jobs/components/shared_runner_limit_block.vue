<script>
import { GlButton } from '@gitlab/ui';
import { s__, sprintf } from '~/locale';

export default {
  components: {
    GlButton,
  },
  props: {
    quotaUsed: {
      type: Number,
      required: true,
    },
    quotaLimit: {
      type: Number,
      required: true,
    },
    runnersPath: {
      type: String,
      required: false,
      default: null,
    },
    projectPath: {
      type: String,
      required: true,
    },
    subscriptionsMoreMinutesUrl: {
      type: String,
      required: false,
      default: null,
    },
  },
  computed: {
    isExpired() {
      return this.artifact.expired;
    },
    runnersWarningMessage() {
      return sprintf(
        s__(
          'Runners|You have used %{quotaUsed} out of %{quotaLimit} of your shared Runners pipeline minutes.',
        ),
        { quotaUsed: this.quotaUsed, quotaLimit: this.quotaLimit },
      );
    },
  },
};
</script>
<template>
  <div class="bs-callout bs-callout-danger">
    <p>
      {{ runnersWarningMessage }}

      <template v-if="runnersPath">
        {{ __('For more information, go to the ') }}
        <a :href="runnersPath">{{ __('Runners page.') }}</a>
      </template>
    </p>
    <gl-button
      v-if="subscriptionsMoreMinutesUrl"
      variant="danger"
      category="primary"
      :href="subscriptionsMoreMinutesUrl"
      class="btn-inverted"
    >
      {{ __('Purchase more minutes') }}
    </gl-button>
  </div>
</template>
