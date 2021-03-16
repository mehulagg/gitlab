<script>
import { s__ } from '~/locale';
import SurveyRequestBanner from './survey_request_banner.vue';

export default {
  components: { SurveyRequestBanner },
  i18n: {
    title: s__('SecurityReports|Security Dashboard'),
  },
};
</script>

<template>
  <div data-testid="security-charts-layout">
    <survey-request-banner v-if="!$slots.loading" class="gl-mt-5" />
    <h2>{{ $options.i18n.title }}</h2>
    <slot name="loading"></slot>
    <div class="security-charts gl-display-flex gl-flex-wrap">
      <slot></slot>
    </div>
    <slot name="empty-state"></slot>
  </div>
</template>
