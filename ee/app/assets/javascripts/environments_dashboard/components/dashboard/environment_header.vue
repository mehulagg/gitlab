<script>
import { GlLink, GlBadge, GlTooltipDirective, GlIcon } from '@gitlab/ui';
import { s__ } from '~/locale';
import ReviewAppLink from '~/vue_merge_request_widget/components/review_app_link.vue';

export default {
  components: {
    GlIcon,
    ReviewAppLink,
    GlBadge,
    GlLink,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    environment: {
      type: Object,
      required: true,
    },
    hasPipelineFailed: {
      type: Boolean,
      required: false,
      default: false,
    },
    hasErrors: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    headerClasses() {
      return {
        'dashboard-card-header-warning': this.hasErrors,
        'dashboard-card-header-failed': this.hasPipelineFailed,
        'bg-light': !this.hasErrors && !this.hasPipelineFailed,
      };
    },
  },
  reviewButtonText: {
    text: s__('Review App|View app'),
    tooltip: '',
  },
  tooltips: {
    information: s__('EnvironmentDashboard|You are looking at the last updated environment'),
  },
};
</script>

<template>
  <div :class="headerClasses" class="card-header border-0 py-2 d-flex align-items-center">
    <div class="flex-grow-1 block-truncated">
      <gl-link
        v-gl-tooltip
        class="js-environment-link cgray"
        :href="environment.environment_path"
        :title="environment.name"
      >
        <span class="js-environment-name bold"> {{ environment.name }}</span>
      </gl-link>
      <gl-badge v-if="environment.within_folder" class="dashboard-card-icon">{{
        environment.size
      }}</gl-badge>
    </div>
    <gl-icon
      v-if="environment.within_folder"
      v-gl-tooltip
      :title="$options.tooltips.information"
      name="information"
      class="dashboard-card-icon"
    />
    <review-app-link
      v-else-if="environment.external_url"
      :link="environment.external_url"
      :display="$options.reviewButtonText"
      css-class="btn btn-default btn-sm"
    />
  </div>
</template>
