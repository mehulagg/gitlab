<script>
import { GlButton, GlLink, GlTooltipDirective } from '@gitlab/ui';
import { __ } from '~/locale';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';
import RunnerInstructions from '~/vue_shared/components/runner_instructions/runner_instructions.vue';

export default {
  components: {
    GlButton,
    GlLink,
    ClipboardButton,
    RunnerInstructions,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    registrationToken: {
      type: String,
      required: true,
    },
    typeName: {
      type: String,
      required: false,
      default: __('shared'),
    },
  },
  computed: {
    runnerInstallHelpPage() {
      return 'https://docs.gitlab.com/runner/install/';
    },
    rootUrl() {
      return gon.gitlab_url;
    },
  },
};
</script>

<template>
  <div class="bs-callout">
    <h5>
      {{ sprintf(__('Set up a %{type} runner manually'), { type: typeName }) }}
    </h5>

    <ol>
      <li>
        <gl-link :href="runnerInstallHelpPage" target="_blank">
          {{ __("Install GitLab Runner and ensure it's running.") }}
        </gl-link>
      </li>
      <li>
        {{ __('Register the runner with this URL:') }}
        <br />

        <code>{{ rootUrl }}</code>
        <clipboard-button :title="__('Copy URL')" :text="rootUrl" />
      </li>
      <li>
        {{ __('And this registration token:') }}
        <br />

        <code>{{ registrationToken }}</code>
        <clipboard-button :title="__('Copy token')" :text="registrationToken" />
      </li>
    </ol>

    <span v-gl-tooltip title="Not implemented in this view">
      <gl-button disabled>
        {{ __('Reset registration token') }}
      </gl-button>
    </span>
    <runner-instructions />
  </div>
</template>
