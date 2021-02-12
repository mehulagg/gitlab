<script>
import {
  GlBadge,
  GlForm,
  GlFormInput,
  GlModal,
  GlSprintf,
  GlSafeHtmlDirective as SafeHtml,
} from '@gitlab/ui';
import csrf from '~/lib/utils/csrf';
import { __, s__, sprintf } from '~/locale';
import Api from 'ee/api';
import {
  REMOVE_MEMBER_MODAL_ID,
  REMOVE_MEMBER_MODAL_CONTENT_TEXT_TEMPLATE,
} from 'ee/billings/seat_usage/constants';
  

export default {
  name: 'RemoveMemberModal',
  csrf,
  components: {
    GlForm,
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
      type: Number | String,
      required: true,
    },
  },
  data() {
    return {
      enteredMemberUsername: null,
    };
  },
  computed: {
    removeMemberPath() {
      return Api.buildUrl(Api.billableGroupMemberPath)
      .replace(':namespace_id', encodeURIComponent(this.namespaceId))
      .replace(':id', encodeURIComponent(this.member.id));
    },
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
        },
      };
    },
  },
  methods: {
    handlePrimary() {
      this.$refs.form.$el.submit();
    },
  },
  modalId: REMOVE_MEMBER_MODAL_ID,
  i18n: {
    actionCancel: {
      text: __('Cancel'),
    },
    inputLabel: s__('Billing|Type %{username} to confirm'),
  },
};
</script>

<template>
  <gl-modal
    v-bind="$attrs"
    :modal-id="$options.modalId"
    :action-primary="actionPrimaryProps"
    :action-cancel="$options.i18n.actionCancel"
    :title="modalTitle"
    data-qa-selector="remove_member_modal"
    :ok-disabled="!canSubmit"
    @primary="handlePrimary"
  >
    <gl-form ref="form" :action="removeMemberPath" method="post">
      <input type="hidden" name="_method" value="delete" />
      <input :value="$options.csrf.token" type="hidden" name="authenticity_token" />

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
    </gl-form>
  </gl-modal>
</template>
