<script>
/* eslint-disable vue/no-v-html */
import {
  GlButton,
  GlDropdown,
  GlDropdownItem,
  GlModal,
  GlSearchBoxByType,
  GlModalDirective,
} from '@gitlab/ui';
import { s__, sprintf } from '~/locale';
import ReviewAppLink from '~/vue_merge_request_widget/components/review_app_link.vue';
import ModalCopyButton from '~/vue_shared/components/modal_copy_button.vue';

export default {
  components: {
    GlButton,
    GlDropdown,
    GlDropdownItem,
    GlModal,
    GlSearchBoxByType,
    ReviewAppLink,
    ModalCopyButton,
  },
  directives: {
    'gl-modal': GlModalDirective,
  },
  props: {
    appMetadata: {
      type: Object,
      required: true,
    },
    changes: {
      type: Array,
      required: false,
      default: () => [],
    },
    cssClass: {
      type: String,
      required: false,
      default: '',
    },
    link: {
      type: String,
      required: true,
    },
    viewAppDisplay: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      modalId: 'visual-review-app-info',
      changesSearchTerm: '',
    };
  },
  computed: {
    copyToClipboard() {
      return {
        script: s__('VisualReviewApp|Copy script'),
        mrId: s__('VisualReviewApp|Copy merge request ID'),
      };
    },
    copyString() {
      /* eslint-disable no-useless-escape */
      return {
        script: `<script defer
  data-project-id='${this.appMetadata.sourceProjectId}'
  data-project-path='${this.appMetadata.sourceProjectPath}'
  <!-- Remove the following line to use the same script for multiple merge requests -->
  data-merge-request-id='${this.appMetadata.mergeRequestId}'
  data-mr-url='${this.appMetadata.appUrl}'
  id='review-app-toolbar-script'
  src='https://gitlab.com/assets/webpack/visual_review_toolbar.js'><\/script>`,
      };
      /* eslint-enable no-useless-escape */
    },
    filteredChanges() {
      return this.changes.filter((change) => change.path.includes(this.changesSearchTerm));
    },
    instructionText() {
      return {
        intro: {
          p1: s__(
            'VisualReviewApp|Follow the steps below to enable Visual Reviews inside your application.',
          ),
          p2: s__(
            'VisualReviewApp|Steps 1 and 2 (and sometimes 3) are performed once by the developer before requesting feedback. Steps 3 (if necessary), 4 is performed by the reviewer each time they perform a review.',
          ),
        },
        step1: sprintf(
          s__('VisualReviewApp|%{stepStart}Step 1%{stepEnd}. Copy the following script:'),
          {
            stepStart: '<strong>',
            stepEnd: '</strong>',
          },
          false,
        ),
        step2: sprintf(
          s__(
            'VisualReviewApp|%{stepStart}Step 2%{stepEnd}. Add it to the %{headTags} tags of every page of your application, ensuring the merge request ID is set or not set as required. ',
          ),
          {
            stepStart: '<strong>',
            stepEnd: '</strong>',
            headTags: `<code>&lt;head&gt;</code>`,
          },
          false,
        ),
        step3: sprintf(
          s__(
            `VisualReviewApp|%{stepStart}Step 3%{stepEnd}. If not previously %{linkStart}configured%{linkEnd} by a developer, enter the merge request ID for the review when prompted. The ID of this merge request is %{stepStart}%{mrId}%{stepStart}.`,
          ),
          {
            stepStart: '<strong>',
            stepEnd: '</strong>',
            linkStart:
              '<a href="https://docs.gitlab.com/ee/ci/review_apps/#configuring-visual-reviews">',
            linkEnd: '</a>',
            mrId: this.appMetadata.mergeRequestId,
          },
          false,
        ),
        step4: sprintf(
          s__('VisualReviewApp|%{stepStart}Step 4%{stepEnd}. Leave feedback in the Review App.'),
          {
            stepStart: '<strong>',
            stepEnd: '</strong>',
          },
          false,
        ),
      };
    },
    modalTitle() {
      return s__('VisualReviewApp|Enable Visual Reviews');
    },
    shouldShowChanges() {
      return this.changes.length > 0;
    },
    isSearchEmpty() {
      return this.filteredChanges.length === 0;
    },
  },
  methods: {
    cancel() {
      this.$refs.modal.cancel();
    },
    ok() {
      this.$refs.modal.ok();
    },
  },
};
</script>
<template>
  <div class="gl-display-inline-flex">
    <gl-button
      v-gl-modal="modalId"
      category="secondary"
      class="gl-ml-3 js-review-button"
      size="small"
      :class="cssClass"
      type="button"
    >
      {{ s__('VisualReviewApp|Review') }}
    </gl-button>
    <gl-modal
      ref="modal"
      :modal-id="modalId"
      :title="modalTitle"
      lazy
      static
      size="lg"
      class="text-2 ws-normal"
    >
      <p v-html="instructionText.intro.p1"></p>
      <p v-html="instructionText.intro.p2"></p>
      <div>
        <p v-html="instructionText.step1"></p>
        <div class="flex align-items-start">
          <pre> {{ copyString.script }} </pre>
          <modal-copy-button
            :title="copyToClipboard.script"
            :text="copyString.script"
            :modal-id="modalId"
            css-classes="border-0"
          />
        </div>
      </div>
      <p v-html="instructionText.step2"></p>
      <p>
        <span v-html="instructionText.step3"></span>
        <modal-copy-button
          :title="copyToClipboard.mrId"
          :text="appMetadata.mergeRequestId.toString()"
          :modal-id="modalId"
          css-classes="border-0 gl-pt-0 gl-pr-0 gl-pl-2 gl-pb-0"
        />
      </p>
      <p v-html="instructionText.step4"></p>
      <template #modal-footer>
        <gl-button category="secondary" @click="cancel">
          {{ s__('VisualReviewApp|Cancel') }}
        </gl-button>
        <gl-dropdown
          v-if="shouldShowChanges"
          :text="s__('VisualReviewApp|Open review app')"
          icon="external-link"
          dropup
          right
          split
          :split-href="link"
          data-track-event="open_review_app"
          data-track-label="review_app"
          @click="ok"
        >
          <gl-search-box-by-type v-model.trim="changesSearchTerm" />
          <gl-dropdown-item
            v-for="change in filteredChanges"
            :key="change.path"
            :href="change.external_url"
            data-track-event="open_review_app"
            data-track-label="review_app"
            >{{ change.path }}</gl-dropdown-item
          >

          <div v-show="isSearchEmpty" class="text-secondary p-2">
            {{ s__('VisualReviewApp|No review app found or available.') }}
          </div>
        </gl-dropdown>
        <review-app-link
          v-else
          :display="viewAppDisplay"
          :link="link"
          css-class="js-deploy-url deploy-link btn btn-default btn-sm inline"
        />
      </template>
    </gl-modal>
  </div>
</template>
