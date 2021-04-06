<script>
import { GlLink, GlCard, GlIcon } from '@gitlab/ui';
import { s__ } from '~/locale';
import { imagePath } from '~/lib/utils/common_utils';
import { ACTION_LABELS } from '../constants';
import LearnGitlabSectionLink from './learn_gitlab_section_link.vue';

export default {
  name: 'LearnGitlabSectionCard',
  components: { GlLink, GlCard, GlIcon, LearnGitlabSectionLink },
  i18n: {
    ACTION_LABELS,
    workspace: {
      title: s__('LearnGitLab|Set up your workspace'),
      description: s__(
        "LearnGitLab|Complete these tasks first so you can enjoy GitLab's features to their fullest:",
      ),
    },
    plan: {
      title: s__('LearnGitLab|Plan and execute'),
      description: s__(
        'LearnGitLab|Create a workflow for your new workspace, and learn how GitLab features work together:',
      ),
    },
    deploy: {
      title: s__('LearnGitLab|Deploy'),
      description: s__(
        'LearnGitLab|Use your new GitLab workflow to deploy your application, monitor its health, and keep it secure:',
      ),
    },
  },
  props: {
    section: {
      required: true,
      type: String,
    },
    actions: {
      required: true,
      type: Object,
    },
  },
  methods: {
    svg(section) {
      return imagePath(`learn_gitlab/section_${section}.svg`);
    },
  },
};
</script>
<template>
  <gl-card class="gl-pt-0 learn-gitlab-section-card">
    <div class="learn-gitlab-section-card-header">
      <img :src="svg(section)" />
      <h2 class="gl-font-lg gl-mb-3">{{ $options.i18n[section].title }}</h2>
      <p class="gl-text-gray-700 gl-mb-6">{{ $options.i18n[section].description }}</p>
    </div>
    <learn-gitlab-section-link
      v-for="(value, action) in actions"
      :key="action"
      :action="action"
      :value="value"
    />
  </gl-card>
</template>
