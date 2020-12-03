<script>
import {
  GlButton,
  GlButtonGroup,
  GlForm,
  GlFormInput,
  GlFormGroup,
  GlFormText,
  GlModal,
} from '@gitlab/ui';
import { debounce } from 'lodash';
import { mapState, mapActions } from 'vuex';
import { sprintf, __, s__ } from '~/locale';
import { capitalizeFirstCharacter } from '~/lib/utils/text_utility';
import { DATA_REFETCH_DELAY } from '../../shared/constants';

const ERRORS = {
  MIN_LENGTH: s__('CreateValueStreamForm|Name is required'),
  MAX_LENGTH: s__('CreateValueStreamForm|Maximum length 100 characters'),
};

const defaultStageFields = {
  name: '',
  isCustom: true, // ? maybe?
  startEventIdentifier: null,
  startEventLabelId: null,
  endEventIdentifier: null,
  endEventLabelId: null,
};

const NAME_MAX_LENGTH = 100;

const validate = ({ name }) => {
  const errors = { name: [] };
  if (name.length > NAME_MAX_LENGTH) {
    errors.name.push(ERRORS.MAX_LENGTH);
  }
  if (!name.length) {
    errors.name.push(ERRORS.MIN_LENGTH);
  }
  return errors;
};

// TODO: move to constants
const I18N = {
  CREATE_VALUE_STREAM: __('Create Value Stream'),
  CREATED: __("'%{name}' Value Stream created"),
  CANCEL: __('Cancel'),
  FIELD_NAME_LABEL: __('Value Stream name'),
  FIELD_NAME_PLACEHOLDER: __('Example: My Value Stream'),
};

const PRESET_OPTIONS = [
  {
    text: s__('CreateValueStreamForm|From default template'),
    value: 'default',
  },
  {
    text: s__('CreateValueStreamForm|From scratch'),
    value: 'scratch',
  },
];

const DEFAULT_STAGE_CONFIG = ['issue', 'plan', 'code', 'test', 'review', 'staging', 'total'].map(
  _id => {
    const title = capitalizeFirstCharacter(_id);
    const id = _id === 'total' ? 'production' : _id;
    return {
      // id,
      title,
      hidden: false,
      // custom: false,
    };
  },
);

export default {
  name: 'ValueStreamForm',
  components: {
    GlButton,
    GlButtonGroup,
    GlForm,
    GlFormInput,
    GlFormGroup,
    GlFormText,
    GlModal,
  },
  props: {
    initialData: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  data() {
    return {
      errors: {},
      name: '',
      selectedPreset: PRESET_OPTIONS[0].value,
      presetOptions: PRESET_OPTIONS,
      stages: DEFAULT_STAGE_CONFIG,
      ...this.initialData,
    };
  },
  computed: {
    ...mapState({
      initialFormErrors: 'createValueStreamErrors',
      isCreating: 'isCreatingValueStream',
    }),
    isValid() {
      return !this.errors.name?.length;
    },
    invalidFeedback() {
      return this.errors.name?.join('\n');
    },
    hasFormErrors() {
      const { initialFormErrors } = this;
      return Boolean(Object.keys(initialFormErrors).length);
    },
    isLoading() {
      return this.isCreating;
    },
    primaryProps() {
      return {
        text: this.$options.I18N.CREATE_VALUE_STREAM,
        attributes: [
          { variant: 'success' },
          { disabled: !this.isValid },
          { loading: this.isLoading },
        ],
      };
    },
  },
  watch: {
    initialFormErrors(newErrors = {}) {
      this.errors = newErrors;
    },
  },
  mounted() {
    const { initialFormErrors } = this;
    if (this.hasFormErrors) {
      this.errors = initialFormErrors;
    } else {
      this.onHandleInput();
    }
  },
  methods: {
    ...mapActions(['createValueStream']),
    onHandleInput: debounce(function debouncedValidation() {
      const { name } = this;
      this.errors = validate({ name });
    }, DATA_REFETCH_DELAY),
    isFirstStage(i) {
      return i === 0;
    },
    isLastStage(i) {
      return i === this.stages?.length - 1;
    },
    onSubmit() {
      const { name, stages } = this;
      return this.createValueStream({ name, stages }).then(() => {
        if (!this.hasFormErrors) {
          this.$toast.show(sprintf(this.$options.I18N.CREATED, { name }), {
            position: 'top-center',
          });
          this.name = '';
        }
      });
    },
  },
  I18N,
};
</script>
<template>
  <gl-modal
    data-testid="value-stream-form-modal"
    modal-id="value-stream-form-modal"
    scrollable
    :title="$options.I18N.CREATE_VALUE_STREAM"
    :action-primary="primaryProps"
    :action-cancel="{ text: $options.I18N.CANCEL }"
    @primary.prevent="onSubmit"
  >
    <gl-form>
      <gl-form-group
        :label="$options.I18N.FIELD_NAME_LABEL"
        label-for="create-value-stream-name"
        :invalid-feedback="invalidFeedback"
        :state="isValid"
      >
        <gl-form-input
          id="create-value-stream-name"
          v-model.trim="name"
          name="create-value-stream-name"
          :placeholder="$options.I18N.FIELD_NAME_PLACEHOLDER"
          :state="isValid"
          required
          @input="onHandleInput"
        />
      </gl-form-group>
      <hr />
      <gl-form-group
        v-for="(stage, i) in stages"
        :key="stage.id"
        :label="sprintf(__('Stage %{i}'), { i: i + 1 })"
      >
        <div class="gl-display-flex gl-flex-direction-row gl-justify-content-space-between">
          <div>
            <gl-form-input
              v-model.trim="stage.title"
              :name="`create-value-stream-stage-${i}`"
              :placeholder="s__('CreateValueStreamForm|Enter stage name')"
              :state="isValid"
              required
              @input="onHandleInput"
            />
          </div>
          <div>
            <gl-button-group>
              <gl-button :disabled="isLastStage(i)" icon="arrow-down" />
              <gl-button :disabled="isFirstStage(i)" icon="arrow-up" />
            </gl-button-group>
            &nbsp;
            <gl-button icon="archive" />
          </div>
        </div>
      </gl-form-group>
    </gl-form>
  </gl-modal>
</template>
