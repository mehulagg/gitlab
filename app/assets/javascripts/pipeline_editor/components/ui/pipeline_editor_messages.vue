<script>
import { GlAlert } from '@gitlab/ui';
import { getParameterValues, removeParams } from '~/lib/utils/url_utility';
import { __, s__ } from '~/locale';
import {
  COMMIT_FAILURE,
  COMMIT_SUCCESS,
  DEFAULT_FAILURE,
  LOAD_FAILURE_UNKNOWN,
} from '../../constants';
import CodeSnippetAlert from '../code_snippet_alert/code_snippet_alert.vue';
import {
  CODE_SNIPPET_SOURCE_URL_PARAM,
  CODE_SNIPPET_SOURCES,
} from '../code_snippet_alert/constants';

export default {
  components: {
    GlAlert,
    CodeSnippetAlert,
  },
  errorTexts: {
    [COMMIT_FAILURE]: s__('Pipelines|The GitLab CI configuration could not be updated.'),
    [DEFAULT_FAILURE]: __('Something went wrong on our end.'),
    [LOAD_FAILURE_UNKNOWN]: s__('Pipelines|The CI configuration was not loaded, please try again.'),
  },
  successTexts: {
    [COMMIT_SUCCESS]: __('Your changes have been successfully committed.'),
  },
  props: {
    failureType: {
      type: String,
      required: false,
      default: null,
    },
    failureReasons: {
      type: Array,
      required: false,
      default: () => [],
    },
    successType: {
      type: String,
      required: false,
      default: null,
    },
  },
  data() {
    return {
      codeSnippetCopiedFrom: '',
      showAlert: false,
    };
  },
  computed: {
    alerts() {
      const messages = [];

      if (this.failureType) {
        messages.push(this.failure);
      }

      if (this.success) {
        messages.push(this.success);
      }
      return messages;
    },
    failure() {
      switch (this.failureType) {
        case LOAD_FAILURE_UNKNOWN:
          return {
            text: this.$options.errorTexts[LOAD_FAILURE_UNKNOWN],
            variant: 'danger',
          };
        case COMMIT_FAILURE:
          return {
            text: this.$options.errorTexts[COMMIT_FAILURE],
            variant: 'danger',
          };
        default:
          return {
            text: this.$options.errorTexts[DEFAULT_FAILURE],
            variant: 'danger',
          };
      }
    },
  },
  success() {
    switch (this.successType) {
      case COMMIT_SUCCESS:
        return {
          text: this.$options.successTexts[COMMIT_SUCCESS],
          variant: 'info',
        };
      default:
        return null;
    }
  },

  created() {
    this.parseCodeSnippetSourceParam();
  },
  methods: {
    dismissAlert() {
      this.showAlert = false;
    },
    dismissCodeSnippetAlert() {
      this.codeSnippetCopiedFrom = '';
    },
    parseCodeSnippetSourceParam() {
      const [codeSnippetCopiedFrom] = getParameterValues(CODE_SNIPPET_SOURCE_URL_PARAM);
      if (codeSnippetCopiedFrom && CODE_SNIPPET_SOURCES.includes(codeSnippetCopiedFrom)) {
        this.codeSnippetCopiedFrom = codeSnippetCopiedFrom;
        window.history.replaceState(
          {},
          document.title,
          removeParams([CODE_SNIPPET_SOURCE_URL_PARAM]),
        );
      }
    },
  },
};
</script>
<template>
  <div>
    <code-snippet-alert
      v-if="codeSnippetCopiedFrom"
      :source="codeSnippetCopiedFrom"
      class="gl-mb-5"
      @dismiss="dismissCodeSnippetAlert"
    />
    <gl-alert
      v-for="alert in alerts"
      :key="alert.text"
      :variant="alert.variant"
      class="gl-mb-5"
      @dismiss="dismissAlert"
    >
      {{ alert.text }}
      <ul v-if="failureReasons.length" class="gl-mb-0">
        <li v-for="reason in failureReasons" :key="reason">{{ reason }}</li>
      </ul>
    </gl-alert>
  </div>
</template>
