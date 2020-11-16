<script>
import { GlModal, GlMarkdown, GlLink, GlSprintf } from '@gitlab/ui';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';
import { __ } from '~/locale';

export default {
  components: {
    GlModal,
    ClipboardButton,
    GlMarkdown,
    GlLink,
    GlSprintf,
  },
  props: {
    canMerge: {
      type: Boolean,
      required: true,
    },
    isFork: {
      type: Boolean,
      required: true,
    },
    sourceProject: {
      type: String,
      required: false,
      default: '',
    },
    sourceBranch: {
      type: String,
      required: false,
      default: '',
    },
    sourceProjectPath: {
      type: String,
      required: false,
      default: '',
    },
    targetBranch: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    mergeInfo1() {
      return `git fetch @merge_request.source_project @merge_request.source_branch git checkout -b @merge_request.source_project_path @merge_request.source_branch FETCH_HEAD`;
    },
    mergeInfo2() {
        return `git fetch @merge_request.source_project @merge_request.source_branch git checkout -b @merge_request.source_project_path @merge_request.source_branch FETCH_HEAD`;
    },
    mergeInfo3() {
        return this.canMerge ? `git push origin "#{h @merge_request.target_branch}"` : __('Note that pushing to GitLab requires write access to this repository.')
    },
  },
};
</script>

<template>
  <gl-modal
    id="modal_merge_info"
    modal-id="modal_merge_info"
    :title="__('Check out, review, and merge locally')"
    no-fade
    :action-primary="{}"
    :action-secondary="{}"
    :action-cancel="{}"
  >
    <p>
      <strong>
        {{ __('Step 1.') }}
      </strong>
      {{ __('Fetch and check out the branch for this merge request') }}
      <clipboard-button :text="mergeInfo1" :title="__('Copy commands')" />
      <gl-markdown>
        <pre v-if="isFork">
                {{ mergeInfo1 }}
            </pre
        >
        <pre v-else>
                {{ mergeInfo1 }}
            </pre
        >
      </gl-markdown>
    </p>
    <p>
      <strong>
        {{ __('Step 2.') }}
      </strong>
      {{ __('Review the changes locally') }}
    </p>
    <p>
      <strong>
        {{ __('Step 3.') }}
      </strong>
      {{ __('Merge the branch and fix any conflicts that come up') }}
    </p>
    <p>
      <strong>
        {{ __('Step 4.') }}
      </strong>
      {{ __('Push the result of the merge to GitLab') }}
    </p>
    <p>
      <strong>
        {{ __('Tip') }}
      </strong>
      <gl-sprintf
        :message="
          __(
            'You can also checkout merge requests locally by %{linkStart}following these guidelines%{linkEnd}',
          )
        "
      >
        <template #link="{ content }">
          <gl-link
            class="gl-display-inline-block"
            href="/user/project/merge_requests/reviewing_and_managing_merge_requests.md#checkout-merge-requests-locally-through-the-head-ref"
            target="_blank"
            >{{ content }}</gl-link
          >
        </template>
      </gl-sprintf>
    </p>
  </gl-modal>
</template>
