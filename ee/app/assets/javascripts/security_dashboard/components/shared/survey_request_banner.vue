<script>
import { GlButton, GlBanner, GlSprintf } from '@gitlab/ui';
import {
  SURVEY_BANNER_LOCAL_STORAGE_KEY,
  SURVEY_BANNER_CURRENT_ID,
} from 'ee/security_dashboard/constants';
import { s__, __ } from '~/locale';
import LocalStorageSync from '~/vue_shared/components/local_storage_sync.vue';
import showToast from '~/vue_shared/plugins/global_toast';

const SURVEY_LINK = 'https://gitlab.fra1.qualtrics.com/jfe/form/SV_7UMsVhPbjmwCp1k';
const DAYS_TO_ASK_LATER = 7;

export default {
  components: { GlButton, GlBanner, GlSprintf, LocalStorageSync },
  inject: ['surveyRequestSvgPath'],
  data: () => ({
    surveyShowDate: null,
  }),
  computed: {
    shouldShowSurvey() {
      const { surveyShowDate } = this;
      const isFeatureEnabled = Boolean(gon.features?.vulnerabilityManagementSurvey);
      const date = new Date(surveyShowDate);

      // Survey is not enabled or user dismissed the survey by clicking the close icon.
      if (!isFeatureEnabled || surveyShowDate === SURVEY_BANNER_CURRENT_ID) {
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
    hideSurvey() {
      this.surveyShowDate = SURVEY_BANNER_CURRENT_ID;
    },
    askLater() {
      const date = new Date();
      date.setDate(date.getDate() + DAYS_TO_ASK_LATER);
      this.surveyShowDate = date.toISOString();

      showToast(this.$options.i18n.toastMessage);
    },
  },
  i18n: {
    title: s__('SecurityReports|Vulnerability Management feature survey'),
    buttonText: s__('SecurityReports|Take survey'),
    askAgainLater: __('Ask again later'),
    description: s__(
      `SecurityReports|At GitLab, we're all about iteration and feedback. That's why we are reaching out to customers like you to help guide what we work on this year for Vulnerability Management. We have a lot of exciting ideas and ask that you assist us by taking a short survey %{boldStart}no longer than 10 minutes%{boldEnd} to evaluate a few of our potential features.`,
    ),
    toastMessage: s__(
      'SecurityReports|Your feedback is important to us! We will ask again in a week.',
    ),
  },
  storageKey: SURVEY_BANNER_LOCAL_STORAGE_KEY,
  surveyLink: SURVEY_LINK,
};
</script>

<template>
  <local-storage-sync v-model="surveyShowDate" :storage-key="$options.storageKey">
    <gl-banner
      v-if="shouldShowSurvey"
      :title="$options.i18n.title"
      :button-text="$options.i18n.buttonText"
      :svg-path="surveyRequestSvgPath"
      :button-link="$options.surveyLink"
      @close="hideSurvey"
    >
      <p>
        <gl-sprintf :message="$options.i18n.description">
          <template #bold="{ content }">
            <span class="gl-font-weight-bold">{{ content }}</span>
          </template>
        </gl-sprintf>
      </p>

      <template #actions>
        <gl-button variant="link" class="gl-ml-5" data-testid="ask-later-button" @click="askLater">
          {{ $options.i18n.askAgainLater }}
        </gl-button>
      </template>
    </gl-banner>
  </local-storage-sync>
</template>
