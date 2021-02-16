<script>
import {
  GlBadge,
  GlFormInput,
  GlModal,
  GlSprintf,
  GlSafeHtmlDirective as SafeHtml,
} from '@gitlab/ui';
import {
  REMOVE_MEMBER_MODAL_ID,
  REMOVE_MEMBER_MODAL_CONTENT_TEXT_TEMPLATE,
} from 'ee/billings/seat_usage/constants';
import csrf from '~/lib/utils/csrf';
import { __, s__, sprintf } from '~/locale';

export default {
  name: 'RemoveMemberModal',
  csrf,
  components: {
    GlFormInput,
    GlModal,
    GlSprintf,
    GlBadge,
  },
  directives: {
    SafeHtml,
  },
  props: {
    member: {
      type: Object,
      required: true,
    },
    namespace: {
      type: String,
      required: true,
    },
    namespaceId: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      enteredMemberUsername: null,
    };
  },
  computed: {
    modalTitle() {
      return sprintf(s__('Billing|Remove user %{username} from your subscription'), {
        username: this.member.username,
      });
    },
    canSubmit() {
      return this.enteredMemberUsername === this.usernameWithoutAt;
    },
    modalText() {
      return REMOVE_MEMBER_MODAL_CONTENT_TEXT_TEMPLATE;
    },
    usernameWithoutAt() {
      return this.member.username.substring(1);
    },
    actionPrimaryProps() {
      return {
        text: __('Remove user'),
        attributes: {
          variant: 'danger',
          disabled: !this.canSubmit,
          class: 'gl-xs-w-full',
        },
      };
    },
    actionCancelProps() {
      return {
        text: __('Cancel'),
        attributes: {
          class: 'gl-xs-w-full',
        },
      };
    },
  },
  modalId: REMOVE_MEMBER_MODAL_ID,
  i18n: {
    inputLabel: s__('Billing|Type %{username} to confirm'),
  },
};
</script>

<template>
  <gl-modal
    v-bind="$attrs"
    :modal-id="$options.modalId"
    :action-primary="actionPrimaryProps"
    :action-cancel="actionCancelProps"
    :title="modalTitle"
    data-qa-selector="remove_member_modal"
    :ok-disabled="!canSubmit"
    @primary="$emit('primary')"
    @secondary="$emit('canceled')"
    @canceled="$emit('canceled')"
  >
    <p>
      <gl-sprintf :message="modalText">
        <template #username
          ><strong>{{ member.username }}</strong></template
        >
        <template #namespace>{{ namespace }}</template>
      </gl-sprintf>
    </p>

    <label id="input-label">
      <gl-sprintf :message="this.$options.i18n.inputLabel">
        <template #username>
          <gl-badge variant="danger">{{ usernameWithoutAt }}</gl-badge>
        </template>
      </gl-sprintf>
    </label>
    <gl-form-input v-model.trim="enteredMemberUsername" aria-labelledby="input-label" />
  </gl-modal>
</template>
