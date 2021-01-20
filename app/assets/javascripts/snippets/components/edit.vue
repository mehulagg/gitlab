<script>
import { GlButton, GlLoadingIcon } from '@gitlab/ui';

import { deprecatedCreateFlash as Flash } from '~/flash';
import { __, sprintf } from '~/locale';
import TitleField from '~/vue_shared/components/form/title.vue';
import { redirectTo, joinPaths } from '~/lib/utils/url_utility';
import FormFooterActions from '~/vue_shared/components/form/form_footer_actions.vue';
import {
  SNIPPET_MARK_EDIT_APP_START,
  SNIPPET_MEASURE_BLOBS_CONTENT,
} from '~/performance/constants';
import eventHub from '~/blob/components/eventhub';
import { performanceMarkAndMeasure } from '~/performance/utils';

import UpdateSnippetMutation from '../mutations/updateSnippet.mutation.graphql';
import CreateSnippetMutation from '../mutations/createSnippet.mutation.graphql';
import { getSnippetMixin } from '../mixins/snippets';
import { SNIPPET_CREATE_MUTATION_ERROR, SNIPPET_UPDATE_MUTATION_ERROR } from '../constants';
import { markBlobPerformance } from '../utils/blob';

import SnippetBlobActionsEdit from './snippet_blob_actions_edit.vue';
import SnippetVisibilityEdit from './snippet_visibility_edit.vue';
import SnippetDescriptionEdit from './snippet_description_edit.vue';

import NewRecaptchaModal from '~/captcha/new_recaptcha_modal.vue';

eventHub.$on(SNIPPET_MEASURE_BLOBS_CONTENT, markBlobPerformance);

export default {
  components: {
    SnippetDescriptionEdit,
    SnippetVisibilityEdit,
    SnippetBlobActionsEdit,
    TitleField,
    FormFooterActions,
    NewRecaptchaModal,
    GlButton,
    GlLoadingIcon,
  },
  mixins: [getSnippetMixin],
  inject: ['selectedLevel'],
  props: {
    markdownPreviewPath: {
      type: String,
      required: true,
    },
    markdownDocsPath: {
      type: String,
      required: true,
    },
    visibilityHelpLink: {
      type: String,
      default: '',
      required: false,
    },
    projectPath: {
      type: String,
      default: '',
      required: false,
    },
  },
  data() {
    return {
      isUpdating: false,
      actions: [],
      snippet: {
        title: '',
        description: '',
        visibilityLevel: this.selectedLevel,
      },
      recaptchaResponse: '',
      needsRecaptchaResponse: false,
      recaptchaSiteKey: '',
      spamLogId: '',
    };
  },
  computed: {
    hasBlobChanges() {
      return this.actions.length > 0;
    },
    hasValidBlobs() {
      return this.actions.every((x) => x.content);
    },
    updatePrevented() {
      return this.snippet.title === '' || !this.hasValidBlobs || this.isUpdating;
    },
    isProjectSnippet() {
      return Boolean(this.projectPath);
    },
    apiData() {
      return {
        id: this.snippet.id,
        title: this.snippet.title,
        description: this.snippet.description,
        visibilityLevel: this.snippet.visibilityLevel,
        blobActions: this.actions,
        // TODO: Is there a cleaner or more idiomatic way to do this conditional assignment in ES6?
        ...(this.spamLogId && { spamLogId: this.spamLogId }),
        ...(this.recaptchaResponse && { captchaResponse: this.recaptchaResponse }),
      };
    },
    saveButtonLabel() {
      if (this.newSnippet) {
        return __('Create snippet');
      }
      return this.isUpdating ? __('Saving') : __('Save changes');
    },
    cancelButtonHref() {
      if (this.newSnippet) {
        return joinPaths('/', gon.relative_url_root, this.projectPath, '-/snippets');
      }
      return this.snippet.webUrl;
    },
  },
  beforeCreate() {
    performanceMarkAndMeasure({ mark: SNIPPET_MARK_EDIT_APP_START });
  },
  created() {
    window.addEventListener('beforeunload', this.onBeforeUnload);
  },
  destroyed() {
    window.removeEventListener('beforeunload', this.onBeforeUnload);
  },
  methods: {
    onBeforeUnload(e = {}) {
      const returnValue = __('Are you sure you want to lose unsaved changes?');

      if (!this.hasBlobChanges || this.isUpdating) return undefined;

      Object.assign(e, { returnValue });
      return returnValue;
    },
    flashAPIFailure(err) {
      const defaultErrorMsg = this.newSnippet
        ? SNIPPET_CREATE_MUTATION_ERROR
        : SNIPPET_UPDATE_MUTATION_ERROR;
      Flash(sprintf(defaultErrorMsg, { err }));
      this.isUpdating = false;
    },
    getAttachedFiles() {
      const fileInputs = Array.from(this.$el.querySelectorAll('[name="files[]"]'));
      return fileInputs.map((node) => node.value);
    },
    createMutation() {
      return {
        mutation: CreateSnippetMutation,
        variables: {
          input: {
            ...this.apiData,
            uploadedFiles: this.getAttachedFiles(),
            projectPath: this.projectPath,
          },
        },
      };
    },
    updateMutation() {
      return {
        mutation: UpdateSnippetMutation,
        variables: {
          input: this.apiData,
        },
      };
    },
    handleFormSubmit() {
      this.isUpdating = true;
      this.$apollo
        .mutate(this.newSnippet ? this.createMutation() : this.updateMutation())
        .then(({ data }) => {
          const baseObj = this.newSnippet ? data?.createSnippet : data?.updateSnippet;

          // NOTE: The mutation uses 'captcha' instead of 'recaptcha', so that they can be applied
          // to future alternative captcha implementations other than reCAPTCHA (e.g. FriendlyCaptcha)
          // without having to change the names and descriptions in the API. However, this modal and
          // its usage is (for now) specific to the reCAPTCHA implementation, so the 'recaptcha'
          // naming convention is used throughout.
          if (baseObj.needsCaptchaResponse) {
            // If we need a reCAPTCHA response, obtain it via showing the modal. The form will
            // be resubmitted after the response is obtained.
            this.requestRecaptchaResponse(baseObj.captchaSiteKey, baseObj.spamLogId);
            return;
          }

          const errors = baseObj?.errors;
          if (errors.length) {
            this.flashAPIFailure(errors[0]);
          } else {
            redirectTo(baseObj.snippet.webUrl);
          }
        })
        .catch((e) => {
          this.flashAPIFailure(e);
        });
    },
    updateActions(actions) {
      this.actions = actions;
    },
    /**
     * Obtain a recaptchaResponse by showing the recaptcha modal.
     *
     * Sets `needsRecaptchaResponse` to true, which will trigger the recaptcha modal to be shown.
     * The form will be resubmitted if the reCAPTCHA is completed.
     *
     * @param recaptchaSiteKey The recaptchaSiteKey which will be stored in data and used by the
     *   modal to display the reCAPTCHA.
     * @param spamLogId The spamLogId which will be stored in data and included when the form
     *   is re-submitted.
     */
    requestRecaptchaResponse(recaptchaSiteKey, spamLogId) {
      this.recaptchaSiteKey = recaptchaSiteKey;
      this.spamLogId = spamLogId;
      this.needsRecaptchaResponse = true;
    },
    /**
     * Handles the recaptchaResponse value obtained via the recaptcha modal:
     *
     * 1. Sets `needsRecaptchaResponse` to false, causing the modal to hide.
     * 2. Sets the obtained recaptchaResponse value in the data.
     * 3. If the recaptchaResponse is not blank, re-submit the form. If it is blank, reset the
     *    isUpdating flag to false.
     *
     * @param recaptchaResponse The recaptchaResponse value emitted from the modal.
     */
    receivedRecaptchaResponse(recaptchaResponse) {
      // Set needsRecaptchaResponse to false to trigger the modal to close
      this.needsRecaptchaResponse = false;
      this.recaptchaResponse = recaptchaResponse;

      if (this.recaptchaResponse) {
        // If the obtained recaptchaResponse is not empty (if the user solved the reCAPTCHA and didn't
        // just close or cancel the modal), resubmit the form using the recaptchaResponse value
        this.handleFormSubmit();
      } else {
        // if the user didn't solve the reCAPTCHA (i.e. if they just closed the modal),
        // finish the update and allow them to continue editing or manually resubmit the form.
        this.isUpdating = false;
      }
    },
  },
};
</script>
<template>
  <form
    class="snippet-form js-quick-submit common-note-form"
    :data-snippet-type="isProjectSnippet ? 'project' : 'personal'"
    data-testid="snippet-edit-form"
    @submit.prevent="handleFormSubmit"
  >
    <gl-loading-icon
      v-if="isLoading"
      :label="__('Loading snippet')"
      size="lg"
      class="loading-animation prepend-top-20 gl-mb-6"
    />
    <template v-else>
      <new-recaptcha-modal
        :recaptcha-site-key="recaptchaSiteKey"
        :needs-recaptcha-response="needsRecaptchaResponse"
        @receivedRecaptchaResponse="receivedRecaptchaResponse"
      />
      <title-field
        id="snippet-title"
        v-model="snippet.title"
        data-qa-selector="snippet_title_field"
        required
        :autofocus="true"
      />
      <snippet-description-edit
        v-model="snippet.description"
        :markdown-preview-path="markdownPreviewPath"
        :markdown-docs-path="markdownDocsPath"
      />
      <snippet-blob-actions-edit :init-blobs="blobs" @actions="updateActions" />

      <snippet-visibility-edit
        v-model="snippet.visibilityLevel"
        :help-link="visibilityHelpLink"
        :is-project-snippet="isProjectSnippet"
      />
      <form-footer-actions>
        <template #prepend>
          <gl-button
            category="primary"
            type="submit"
            variant="success"
            :disabled="updatePrevented"
            data-qa-selector="submit_button"
            data-testid="snippet-submit-btn"
            >{{ saveButtonLabel }}</gl-button
          >
        </template>
        <template #append>
          <gl-button type="cancel" data-testid="snippet-cancel-btn" :href="cancelButtonHref">{{
            __('Cancel')
          }}</gl-button>
        </template>
      </form-footer-actions>
    </template>
  </form>
</template>
