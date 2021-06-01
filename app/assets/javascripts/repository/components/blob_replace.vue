<script>
import {
  GlButton,
  GlModal,
  GlModalDirective,
  GlLink,
  GlSprintf,
  GlFormGroup,
  GlFormInput,
  GlFormTextarea,
} from '@gitlab/ui';
import { uniqueId } from 'lodash';
import { __ } from '~/locale';
import UploadDropzone from '~/vue_shared/components/upload_dropzone/upload_dropzone.vue';

// app/views/projects/blob/show.html.haml
// app/views/projects/blob/_upload.html.haml
export default {
  i18n: {
    cancel: __('Cancel'),
    replaceFile: __('Replace file'),
    replace: __('Replace'),
    dropDescription: __('Attach a file by drag & drop or %{linkStart}click to upload%{linkEnd}'),
    commitMessage: __('Commit message'),
    targetBranch: __('Target Branch'),
  },
  components: {
    GlButton,
    GlModal,
    UploadDropzone,
    GlLink,
    GlSprintf,
    GlFormGroup,
    GlFormInput,
    GlFormTextarea,
  },
  directives: {
    GlModal: GlModalDirective,
  },
  props: {
    name: {
      type: String,
      required: true,
    },
  },
  computed: {
    replaceModalId() {
      return uniqueId('replace-modal');
    },
    title() {
      console.log('>>>>', this.$router);
      return __(`Replace ${this.name}`);
    },
  },
  methods: {
    cancelReplace() {
      this.$refs.replaceModal.hide();
    },
  },
};
</script>

<template>
  <div class="gl-mr-3">
    <gl-button v-gl-modal="replaceModalId">
      {{ $options.i18n.replace }}
    </gl-button>
    <gl-modal ref="replaceModal" :modal-id="replaceModalId" :title="title" no-fade>
      <upload-dropzone class="gl-h-200!" :drop-description-message="$options.i18n.dropDescription">
        <template #upload-text>
          <gl-sprintf :message="$options.i18n.dropDescription">
            <template #link="{ content }">
              <gl-link>
                {{ content }}
              </gl-link>
            </template>
          </gl-sprintf>
        </template>
      </upload-dropzone>
      <div class="gl-mt-6">
        <gl-form-group
          :label="$options.i18n.commitMessage"
          label-cols-lg="2"
          label-align-lg="right"
        >
          <gl-form-textarea :value="title" />
        </gl-form-group>
        <gl-form-group :label="$options.i18n.targetBranch" label-cols-lg="2" label-align-lg="right">
          <gl-form-input :value="title" />
        </gl-form-group>
      </div>

      <template #modal-footer>
        <div class="gl-w-full gl-display-flex gl-justify-content-space-between">
          <gl-button category="primary" variant="confirm">
            {{ $options.i18n.replaceFile }}
          </gl-button>
          <gl-button @click="cancelReplace">
            {{ $options.i18n.cancel }}
          </gl-button>
        </div>
      </template>
    </gl-modal>
  </div>
</template>
