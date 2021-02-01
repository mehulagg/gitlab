<script>
import {
  GlAlert,
  GlButton,
  GlForm,
  GlFormGroup,
  GlFormInput,
  GlLink,
  GlLoadingIcon,
  GlSprintf,
} from '@gitlab/ui';
import { isEmpty } from 'lodash';

import { helpPagePath } from '~/helpers/help_page_helper';
import { validateHexColor } from '~/lib/utils/color_utils';
import { __, s__ } from '~/locale';
import ColorPicker from '~/vue_shared/components/color_picker/color_picker.vue';

const hasRequiredProperties = (value) => {
  if (isEmpty(value)) {
    return true;
  }

  return ['name', 'description', 'color'].every((prop) => value[prop]);
};

export default {
  components: {
    ColorPicker,
    GlAlert,
    GlButton,
    GlForm,
    GlFormGroup,
    GlFormInput,
    GlLink,
    GlLoadingIcon,
    GlSprintf,
  },
  props: {
    complianceFramework: {
      type: Object,
      required: false,
      default: () => ({}),
      validator: hasRequiredProperties,
    },
    error: {
      type: String,
      required: false,
      default: null,
    },
    groupEditPath: {
      type: String,
      required: true,
    },
    loading: {
      type: Boolean,
      required: false,
      default: false,
    },
    renderForm: {
      type: Boolean,
      required: false,
      default: true,
    },
  },
  data() {
    return {
      name: null,
      description: null,
      color: null,
    };
  },
  computed: {
    isValidColor() {
      return validateHexColor(this.color);
    },
    isValidName() {
      if (this.name === null) {
        return null;
      }

      return Boolean(this.name);
    },
    isValidDescription() {
      if (this.description === null) {
        return null;
      }

      return Boolean(this.description);
    },
    disableSubmitBtn() {
      return !this.isValidName || !this.isValidDescription || !this.isValidColor;
    },
    scopedLabelsHelpPath() {
      return helpPagePath('user/project/labels.md', { anchor: 'scoped-labels' });
    },
  },
  watch: {
    complianceFramework: {
      handler() {
        if (!isEmpty(this.complianceFramework)) {
          this.name = this.complianceFramework.name;
          this.description = this.complianceFramework.description;
          this.color = this.complianceFramework.color;
        }
      },
      immediate: true,
    },
  },
  methods: {
    onSubmit() {
      const { name, description, color } = this;

      this.$emit('submit', { name, description, color });
    },
  },
  i18n: {
    titleInputLabel: __('Title'),
    titleInputDescription: s__(
      'ComplianceFrameworks|Use %{codeStart}::%{codeEnd} to create a %{linkStart}scoped set%{linkEnd} (eg. %{codeStart}SOX::AWS%{codeEnd})',
    ),
    titleInputInvalid: __('A title is required'),
    descriptionInputLabel: __('Description'),
    descriptionInputInvalid: __('A description is required'),
    colorInputLabel: __('Background color'),
    submitBtnText: __('Save changes'),
    cancelBtnText: __('Cancel'),
  },
};
</script>
<template>
  <div class="gl-border-t-1 gl-border-t-solid gl-border-t-gray-100">
    <gl-alert v-if="error" class="gl-mt-5" variant="danger" :dismissible="false">
      {{ error }}
    </gl-alert>
    <gl-loading-icon v-if="loading" size="lg" class="gl-mt-5" />

    <gl-form v-if="renderForm" @submit.prevent="onSubmit">
      <gl-form-group
        :label="$options.i18n.titleInputLabel"
        :invalid-feedback="$options.i18n.titleInputInvalid"
        :state="isValidName"
        data-testid="name-input-group"
      >
        <template #description>
          <gl-sprintf :message="$options.i18n.titleInputDescription">
            <template #code="{ content }">
              <code>{{ content }}</code>
            </template>

            <template #link="{ content }">
              <gl-link :href="scopedLabelsHelpPath" target="_blank">{{ content }}</gl-link>
            </template>
          </gl-sprintf>
        </template>

        <gl-form-input :value="name" data-testid="name-input" @input="name = $event" />
      </gl-form-group>

      <gl-form-group
        :label="$options.i18n.descriptionInputLabel"
        :invalid-feedback="$options.i18n.descriptionInputInvalid"
        :state="isValidDescription"
        data-testid="description-input-group"
      >
        <gl-form-input
          :value="description"
          data-testid="description-input"
          @input="description = $event"
        />
      </gl-form-group>

      <color-picker
        :value="color"
        :label="$options.i18n.colorInputLabel"
        :set-color="color || ''"
        :state="isValidColor"
        @input="color = $event"
      />

      <div
        class="gl-display-flex gl-justify-content-space-between gl-pt-5 gl-border-t-1 gl-border-t-solid gl-border-t-gray-100"
      >
        <gl-button
          type="submit"
          variant="success"
          class="js-no-auto-disable"
          data-testid="submit-btn"
          :disabled="disableSubmitBtn"
          >{{ $options.i18n.submitBtnText }}</gl-button
        >
        <gl-button :href="groupEditPath" data-testid="cancel-btn">{{
          $options.i18n.cancelBtnText
        }}</gl-button>
      </div>
    </gl-form>
  </div>
</template>
