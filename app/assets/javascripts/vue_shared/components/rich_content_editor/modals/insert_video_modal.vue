<script>
import { GlModal, GlFormGroup, GlFormInput } from '@gitlab/ui';
import { isSafeURL } from '~/lib/utils/url_utility';
import { __ } from '~/locale';

export default {
  components: {
    GlModal,
    GlFormGroup,
    GlFormInput,
  },
  data() {
    return {
      url: null,
    };
  },
  modalTitle: __('Insert video'),
  okTitle: __('Insert video'),
  label: __('YouTube URL or ID'),
  computed: {
    altText() {
      return this.description;
    },
  },
  methods: {
    show() {
      this.urlError = null;
      this.url = null;

      this.$refs.modal.show();
    },
    onOk(event) {
      this.submitURL(event);
    },
    submitURL(event) {
      /*if (!this.validateUrl()) {
        event.preventDefault();
        return;
      }*/

      const { url } = this;

      this.$emit('insertVideo', { url });
    },
    validateUrl() {
      if (!isSafeURL(this.url)) {
        this.urlError = __('Please provide a valid URL');
        this.$refs.urlInput.$el.focus();
        return false;
      }

      return true;
    },
  },
};
</script>
<template>
  <gl-modal
    ref="modal"
    modal-id="insert-video-modal"
    :title="$options.modalTitle"
    :ok-title="$options.okTitle"
    @ok="onOk"
  >
    <gl-form-group :label="$options.label" label-for="url-input">
      <gl-form-input id="url-input" ref="urlInput" v-model="url" />
    </gl-form-group>
  </gl-modal>
</template>
