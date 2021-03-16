<script>
import { GlButton, GlBanner, GlSafeHtmlDirective as SafeHtml } from '@gitlab/ui';
import { s__ } from '~/locale';
import LocalStorageSync from '~/vue_shared/components/local_storage_sync.vue';
import showToast from '~/vue_shared/plugins/global_toast';
import { SURVEY_REQUEST_LOCAL_STORAGE_KEY, SURVEY_REQUEST_NEVER_SHOW_VALUE } from '../constants';

export default {
  components: { GlButton, GlBanner, LocalStorageSync },
  directives: { SafeHtml },
  inject: ['surveyRequestSvgPath'],
  data: () => ({
    surveyShowDate: null,
  }),
  computed: {
    shouldShowSurvey() {
      const date = new Date(this.surveyShowDate);

      // User dismissed the survey by clicking the close icon, never show it again.
      if (this.surveyShowDate === SURVEY_REQUEST_NEVER_SHOW_VALUE) {
        return false;
      }
      // Date is invalid, we should show the survey.
      else if (Number.isNaN(date.getDate())) {
        return true;
      }

      return date <= Date.now();
    },
  },
  methods: {
    handleClose() {
      this.surveyShowDate = SURVEY_REQUEST_NEVER_SHOW_VALUE;
    },
    handleAskLater() {
      const date = new Date();
      date.setDate(date.getDate() + 7);
      this.surveyShowDate = date.toISOString();

      showToast(
        s__('SecurityReports|Your feedback is important to us! We will ask again in a week.'),
      );
    },
  },
  i18n: {
    title: s__('SecurityReports|Vulnerability Management feature survey'),
    buttonText: s__('SecurityReports|Take survey'),
    description: s__(
      `SecurityReports|At GitLab, we're all about iteration and feedback. That's why we are reaching out to customers like you to help guide what we work on this year for Vulnerability Management. We have a lot of exciting ideas and ask that you assist us by taking a short survey <span class="gl-font-weight-bold">no longer than 10 minutes</span> to evaluate a few of our potential features.`,
    ),
  },
  storageKey: SURVEY_REQUEST_LOCAL_STORAGE_KEY,
};
</script>

<template>
  <local-storage-sync v-model="surveyShowDate" :storage-key="$options.storageKey">
    <gl-banner
      v-if="shouldShowSurvey"
      :title="$options.i18n.title"
      :button-text="$options.i18n.buttonText"
      :svg-path="surveyRequestSvgPath"
      button-link="https://gitlab.fra1.qualtrics.com/jfe/form/SV_7UMsVhPbjmwCp1k"
      @close="handleClose"
    >
      <p v-safe-html="$options.i18n.description"></p>

      <gl-button variant="link" @click="handleAskLater">{{ __('Ask again later') }}</gl-button>

      <template #actions>
        <gl-button variant="link" @click="handleAskLater">{{ __('Ask again later') }}</gl-button>
      </template>
    </gl-banner>
  </local-storage-sync>
</template>
