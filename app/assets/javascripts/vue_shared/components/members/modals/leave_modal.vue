<script>
import { mapState } from 'vuex';
import { GlModal, GlSprintf, GlModalDirective, GlTooltipDirective } from '@gitlab/ui';
import csrf from '~/lib/utils/csrf';
import { __, s__, sprintf } from '~/locale';
import { LEAVE_MODAL_ID } from '../constants';

export default {
  name: 'LeaveModal',
  actionCancel: {
    text: __('Cancel'),
  },
  actionPrimary: {
    text: __('Leave'),
    attributes: {
      variant: 'danger',
    },
  },
  csrf,
  modalId: LEAVE_MODAL_ID,
  components: { GlModal, GlSprintf },
  directives: {
    GlModalDirective,
    GlTooltip: GlTooltipDirective,
  },
  props: {
    member: {
      type: Object,
      required: true,
    },
  },
  computed: {
    ...mapState(['memberPath']),
    leavePath() {
      return this.memberPath.replace(/:id$/, 'leave');
    },
    modalTitle() {
      return sprintf(s__('Members|Leave "%{source}"'), { source: this.member.source.name });
    },
    modalContent() {
      return s__('Members|Are you sure you want to leave "%{source}"?');
    },
  },
  methods: {
    handlePrimary() {
      this.$refs.form.submit();
    },
  },
};
</script>

<template>
  <gl-modal
    v-bind="$attrs"
    :modal-id="$options.modalId"
    :title="modalTitle"
    :action-primary="$options.actionPrimary"
    :action-cancel="$options.actionCancel"
    size="sm"
    @primary="handlePrimary"
  >
    <form ref="form" :action="leavePath" method="post">
      <p>
        <gl-sprintf :message="modalContent">
          <template #source>{{ member.source.name }}</template>
        </gl-sprintf>
      </p>

      <input type="hidden" name="_method" value="delete" />
      <input :value="$options.csrf.token" type="hidden" name="authenticity_token" />
    </form>
  </gl-modal>
</template>
