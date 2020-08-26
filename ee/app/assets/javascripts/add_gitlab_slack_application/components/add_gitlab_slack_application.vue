<script>
/* eslint-disable @gitlab/vue-require-i18n-strings */
import { __ } from '~/locale';
import { deprecatedCreateFlash as Flash } from '~/flash';
import { redirectTo } from '~/lib/utils/url_utility';
import { spriteIcon } from '~/lib/utils/common_utils';

import GitlabSlackService from '../services/gitlab_slack_service';

export default {
  props: {
    projects: {
      type: Array,
      required: false,
      default: () => [],
    },

    isSignedIn: {
      type: Boolean,
      required: true,
    },

    gitlabForSlackGifPath: {
      type: String,
      required: true,
    },

    signInPath: {
      type: String,
      required: true,
    },

    slackLinkPath: {
      type: String,
      required: true,
    },

    gitlabLogoPath: {
      type: String,
      required: true,
    },

    slackLogoPath: {
      type: String,
      required: true,
    },

    docsPath: {
      type: String,
      required: true,
    },
  },

  data() {
    return {
      popupOpen: false,
      selectedProjectId: this.projects && this.projects.length ? this.projects[0].id : 0,
    };
  },

  computed: {
    doubleHeadedArrowSvg() {
      return spriteIcon('double-headed-arrow');
    },

    arrowRightSvg() {
      return spriteIcon('arrow-right');
    },

    hasProjects() {
      return this.projects.length > 0;
    },
  },

  methods: {
    togglePopup() {
      this.popupOpen = !this.popupOpen;
    },

    addToSlack() {
      GitlabSlackService.addToSlack(this.slackLinkPath, this.selectedProjectId)
        .then(response => redirectTo(response.data.add_to_slack_link))
        .catch(() => Flash(__('Unable to build Slack link.')));
    },
  },

  emits: [],
};
</script>

<template>
  <div class="text-center">
    <h1>{{ __('GitLab for Slack') }}</h1>
    <p>{{ __('Track your GitLab projects with GitLab for Slack.') }}</p>

    <div v-once class="prepend-top-20 append-bottom-20">
      <img :src="gitlabLogoPath" class="gitlab-slack-logo" />
      <div
        class="gitlab-slack-double-headed-arrow inline prepend-left-20 append-right-20"
        v-html="doubleHeadedArrowSvg"
      ></div>
      <img :src="slackLogoPath" class="gitlab-slack-logo" />
    </div>

    <button type="button" class="btn btn-red mx-auto js-popup-button gl-mt-3" @click="togglePopup">
      {{ __('Add GitLab to Slack') }}
    </button>

    <div
      v-if="popupOpen"
      class="popup gitlab-slack-popup mx-auto prepend-top-20 text-center js-popup"
    >
      <div v-if="isSignedIn && hasProjects" class="inline">
        <strong>{{ __('Select GitLab project to link with your Slack team') }}</strong>

        <select v-model="selectedProjectId" class="js-project-select form-control gl-mt-3 gl-mb-3">
          <option v-for="project in projects" :key="project.id" :value="project.id">
            {{ project.name }}
          </option>
        </select>

        <button type="button" class="btn btn-red float-right js-add-button" @click="addToSlack">
          {{ __('Add to Slack') }}
        </button>
      </div>

      <span v-else-if="isSignedIn && !hasProjects" class="js-no-projects">{{
        __("You don't have any projects available.")
      }}</span>

      <span v-else>
        You have to
        <a v-once :href="signInPath" class="js-gitlab-slack-sign-in-link">{{ __('log in') }}</a>
      </span>
    </div>

    <div class="center prepend-top-20 gl-mb-3 gl-mr-2 gl-ml-2">
      <img v-once :src="gitlabForSlackGifPath" class="gitlab-slack-gif" />
    </div>

    <div v-once class="text-center">
      <h3>{{ __('How it works') }}</h3>

      <div class="well gitlab-slack-well mx-auto">
        <code class="code mx-auto gl-mb-3"
          >/gitlab &lt;project-alias&gt; issue show &lt;id&gt;</code
        >
        <span>
          <div class="gitlab-slack-right-arrow inline gl-mr-2" v-html="arrowRightSvg"></div>
          Shows the issue with id <strong>&lt;id&gt;</strong>
        </span>

        <div class="gl-mt-3">
          <a v-once :href="docsPath">{{ __('More Slack commands') }}</a>
        </div>
      </div>
    </div>
  </div>
</template>
