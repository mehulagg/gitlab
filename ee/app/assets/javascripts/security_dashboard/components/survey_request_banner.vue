<script>
import { GlButton, GlIcon, GlSafeHtmlDirective as SafeHtml } from '@gitlab/ui';
import { s__ } from '~/locale';
import showToast from '~/vue_shared/plugins/global_toast';

export default {
  components: { GlButton, GlIcon },
  directives: { SafeHtml },
  inject: ['surveyRequestSvgPath'],
  computed: {
    style() {
      return {
        background: `url(${this.surveyRequestSvgPath}) center/190%`, // eslint-disable-line @gitlab/require-i18n-strings
        width: '7.5em',
        height: '7.5em',
      };
    },
  },
  methods: {
    handleClose() {
      this.$emit('close');
      // showToast(
      //   s__('SecurityReports|Your feedback is important to us! We will ask again in 7 days.'),
      // );
    },
  },
  i18n: {
    title: s__('SecurityReports|Vulnerability Management feature survey'),
    buttonText: s__('SecurityReports|Take survey'),
    description: s__(
      `SecurityReports|At GitLab, we're all about iteration and feedback. That's why we are reaching out to customers like you to help guide what we work on this year for Vulnerability Management. We have a lot of exciting ideas and ask that you assist us by taking a short survey <span class="gl-font-weight-bold">no longer than 10 minutes</span> to evaluate a few of our potential features.`,
    ),
  },
};
</script>

<template>
  <section class="gl-banner">
    <div class="gl-banner-illustration gl-background-center" :style="style"></div>

    <div class="gl-banner-content">
      <h1 class="gl-banner-title">{{ $options.i18n.title }}</h1>
      <p v-safe-html="$options.i18n.description"></p>
      <gl-button
        variant="confirm"
        target="_blank"
        href="https://gitlab.fra1.qualtrics.com/jfe/form/SV_7UMsVhPbjmwCp1k"
      >
        {{ $options.i18n.buttonText }}
      </gl-button>
      <!--      <gl-button variant="link" class="gl-ml-5">{{ __(`Don't show again`) }}</gl-button>-->
    </div>
    <gl-button
      category="tertiary"
      size="small"
      icon="close"
      class="gl-banner-close"
      @click="handleClose"
    />
  </section>
</template>
