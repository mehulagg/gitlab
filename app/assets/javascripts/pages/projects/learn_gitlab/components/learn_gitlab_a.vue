<script>
import { GlCard, GlIcon, GlLink, GlProgressBar, GlSprintf } from '@gitlab/ui';
import { s__ } from '~/locale';
import { ACTION_LABELS } from '../constants';
import LearnGitlabSectionCard from './learn_gitlab_section_card.vue';

export default {
  components: { GlCard, GlIcon, GlLink, GlProgressBar, GlSprintf, LearnGitlabSectionCard },
  i18n: {
    ACTION_LABELS,
    title: s__('LearnGitLab|Learn GitLab'),
    description: s__(
      'LearnGitLab|Ready to get started with GitLab? Follow these steps to set up your workspace, plan and commit changes, and deploy your project.',
    ),
    percentageCompleted: s__(`LearnGitLab|%{percentage}%{percentSymbol} completed`),
  },
  props: {
    actions: {
      required: true,
      type: Object,
    },
  },
  maxValue: Object.keys(ACTION_LABELS).length,
  computed: {
    sections() {
      return [...new Set(Object.values(ACTION_LABELS).map((a) => a.section))];
    },
  },
  methods: {
    progressValue() {
      return Object.values(this.actions).filter((a) => a.completed).length;
    },
    progressPercentage() {
      return Math.round((this.progressValue() / this.$options.maxValue) * 100);
    },
    actionsFor(section) {
      const actions = Object.fromEntries(
        Object.entries(this.actions).filter(
          ([action, value]) => ACTION_LABELS[action].section === section,
        ),
      );
      return actions;
    },
  },
};
</script>
<template>
  <div>
    <div class="row">
      <div class="gl-mb-7 col-md-8 col-lg-7">
        <h1 class="gl-font-size-h1">{{ $options.i18n.title }}</h1>
        <p class="gl-text-gray-700 gl-mb-0">{{ $options.i18n.description }}</p>
      </div>
    </div>
    <div class="gl-mb-3">
      <p class="gl-text-gray-500 gl-mb-2" data-testid="completion-percentage">
        <gl-sprintf :message="$options.i18n.percentageCompleted">
          <template #percentage>{{ progressPercentage() }}</template>
          <template #percentSymbol>%</template>
        </gl-sprintf>
      </p>
      <gl-progress-bar :value="progressValue()" :max="$options.maxValue" />
    </div>
    <div class="row row-cols-1 row-cols-md-3 row-cols-lg-3">
      <div class="col gl-mb-6" v-for="section in this.sections">
        <learn-gitlab-section-card :section="section" :actions="actionsFor(section)" />
      </div>
    </div>
  </div>
</template>
