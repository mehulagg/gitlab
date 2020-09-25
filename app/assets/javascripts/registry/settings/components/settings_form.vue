<script>
import { GlCard, GlButton, GlLoadingIcon } from '@gitlab/ui';
import Tracking from '~/tracking';
import {
  UPDATE_SETTINGS_ERROR_MESSAGE,
  UPDATE_SETTINGS_SUCCESS_MESSAGE,
} from '../../shared/constants';
import ExpirationPolicyFields from '../../shared/components/expiration_policy_fields.vue';
import { SET_CLEANUP_POLICY_BUTTON, CLEANUP_POLICY_CARD_HEADER } from '../constants';
import { formOptionsGenerator } from '~/registry/shared/utils';
import updateContainerExpirationPolicyMutation from '../graphql/mutations/update_container_expiration_policy.graphql';
import { updateContainerExpirationPolicy } from '../graphql/utils/cache_update';

export default {
  components: {
    GlCard,
    GlButton,
    GlLoadingIcon,
    ExpirationPolicyFields,
  },
  mixins: [Tracking.mixin()],
  inject: ['projectPath'],
  props: {
    value: {
      type: Object,
      required: true,
    },
    isLoading: {
      type: Boolean,
      default: false,
      required: false,
    },
    isEdited: {
      type: Boolean,
      default: false,
      required: false,
    },
  },
  labelsConfig: {
    cols: 3,
    align: 'right',
  },
  formOptions: formOptionsGenerator(),
  i18n: {
    CLEANUP_POLICY_CARD_HEADER,
    SET_CLEANUP_POLICY_BUTTON,
  },
  data() {
    return {
      tracking: {
        label: 'docker_container_retention_and_expiration_policies',
      },
      fieldsAreValid: true,
      apiErrors: null,
    };
  },
  computed: {
    isSubmitButtonDisabled() {
      return !this.fieldsAreValid || this.isLoading;
    },
    isCancelButtonDisabled() {
      return !this.isEdited || this.isLoading;
    },
    mutationVariables() {
      return {
        projectPath: this.projectPath,
        enabled: this.value.enabled,
        cadence: this.value.cadence,
        olderThan: this.value.olderThan,
        keepN: this.value.keepN,
        nameRegex: this.value.nameRegex,
        nameRegexKeep: this.value.nameRegexKeep,
      };
    },
  },
  methods: {
    reset() {
      this.track('reset_form');
      this.apiErrors = null;
      this.$emit('reset');
    },
    setApiErrors(response) {
      this.apiErrors = response.graphQLErrors.reduce((acc, curr) => {
        curr.extensions.problems.forEach(item => {
          acc[item.path[0]] = item.message;
        });
        return acc;
      }, {});
    },
    submit() {
      this.track('submit_form');
      this.apiErrors = null;
      return this.$apollo
        .mutate({
          mutation: updateContainerExpirationPolicyMutation,
          variables: {
            input: this.mutationVariables,
          },
          update: updateContainerExpirationPolicy(this.projectPath),
        })
        .then(data => {
          if (data?.errors?.length > 0) {
            this.setApiErrors(data.errors);
          }
          this.$toast.show(UPDATE_SETTINGS_SUCCESS_MESSAGE, { type: 'success' });
        })
        .catch(error => {
          this.setApiErrors(error);
          this.$toast.show(UPDATE_SETTINGS_ERROR_MESSAGE, { type: 'error' });
        });
    },
    onModelChange(changePayload) {
      this.$emit('input', changePayload.newValue);
      if (this.apiErrors) {
        this.apiErrors[changePayload.modified] = undefined;
      }
    },
  },
};
</script>

<template>
  <form ref="form-element" @submit.prevent="submit" @reset.prevent="reset">
    <gl-card>
      <template #header>
        {{ $options.i18n.CLEANUP_POLICY_CARD_HEADER }}
      </template>
      <template #default>
        <expiration-policy-fields
          :value="value"
          :form-options="$options.formOptions"
          :is-loading="isLoading"
          :api-errors="apiErrors"
          @validated="fieldsAreValid = true"
          @invalidated="fieldsAreValid = false"
          @input="onModelChange"
        />
      </template>
      <template #footer>
        <gl-button
          ref="cancel-button"
          type="reset"
          class="gl-mr-3 gl-display-block float-right"
          :disabled="isCancelButtonDisabled"
        >
          {{ __('Cancel') }}
        </gl-button>
        <gl-button
          ref="save-button"
          type="submit"
          :disabled="isSubmitButtonDisabled"
          variant="success"
          category="primary"
          class="js-no-auto-disable"
        >
          {{ $options.i18n.SET_CLEANUP_POLICY_BUTTON }}
          <gl-loading-icon v-if="isLoading" class="gl-ml-3" />
        </gl-button>
      </template>
    </gl-card>
  </form>
</template>
