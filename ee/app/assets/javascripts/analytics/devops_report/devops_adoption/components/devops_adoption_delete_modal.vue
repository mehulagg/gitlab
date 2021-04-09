<script>
import { GlModal, GlSprintf, GlAlert } from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import { DEVOPS_ADOPTION_STRINGS, DEVOPS_ADOPTION_SEGMENT_DELETE_MODAL_ID } from '../constants';
import deleteDevopsAdoptionSegmentMutation from '../graphql/mutations/delete_devops_adoption_segment.mutation.graphql';

export default {
  name: 'DevopsAdoptionDeleteModal',
  components: { GlModal, GlSprintf, GlAlert },
  i18n: DEVOPS_ADOPTION_STRINGS.deleteModal,
  devopsSegmentDeleteModalId: DEVOPS_ADOPTION_SEGMENT_DELETE_MODAL_ID,
  props: {
    segment: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      loading: false,
      errors: [],
    };
  },
  computed: {
    cancelOptions() {
      return {
        text: this.$options.i18n.cancel,
        attributes: [{ disabled: this.loading }],
      };
    },
    primaryOptions() {
      return {
        text: this.$options.i18n.confirm,
        attributes: [
          {
            variant: 'danger',
            loading: this.loading,
          },
        ],
      };
    },
    displayError() {
      return this.errors[0];
    },
    displayName() {
      return this.segment.namespace?.fullName;
    },
  },
  methods: {
    async deleteSegment() {
      try {
        const {
          segment: { id },
        } = this;

        this.loading = true;

        const {
          data: {
            deleteDevopsAdoptionSegment: { errors },
          },
        } = await this.$apollo.mutate({
          mutation: deleteDevopsAdoptionSegmentMutation,
          variables: {
            id: [id],
          },
          update: () => {
            this.$emit('segmentsRemoved', [id]);
          },
        });

        if (errors.length) {
          this.errors = errors;
        } else {
          this.$refs.modal.hide();
        }
      } catch (error) {
        this.errors.push(this.$options.i18n.error);
        Sentry.captureException(error);
      } finally {
        this.loading = false;
      }
    },
    clearErrors() {
      this.errors = [];
    },
  },
};
</script>
<template>
  <gl-modal
    ref="modal"
    :modal-id="$options.devopsSegmentDeleteModalId"
    size="sm"
    :action-primary="primaryOptions"
    :action-cancel="cancelOptions"
    @primary.prevent="deleteSegment"
    @hide="$emit('trackModalOpenState', false)"
    @show="$emit('trackModalOpenState', true)"
  >
    <template #modal-title>{{ $options.i18n.title }}</template>
    <gl-alert v-if="errors.length" variant="danger" class="gl-mb-3" @dismiss="clearErrors">
      {{ displayError }}
    </gl-alert>
    <gl-sprintf :message="$options.i18n.confirmationMessage">
      <template #name
        ><strong>{{ displayName }}</strong></template
      >
    </gl-sprintf>
  </gl-modal>
</template>
