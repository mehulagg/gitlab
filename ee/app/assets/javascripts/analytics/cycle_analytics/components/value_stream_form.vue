<script>
import {
  GlButton,
  GlButtonGroup,
  GlForm,
  GlFormInput,
  GlFormInputGroup,
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

const DEFAULT_STAGE_CONFIG = ['issue', 'plan', 'code', 'test', 'review', 'staging'].map(
  (id, index) => ({
    id,
    name: capitalizeFirstCharacter(id),
    custom: false,
    hidden: false,
    index,
    move_after_id: null,
    move_before_id: null,
  }),
);

const DIRECTION = {
  UP: 'UP',
  DOWN: 'DOWN',
};

export default {
  name: 'ValueStreamForm',
  components: {
    GlButton,
    GlButtonGroup,
    GlForm,
    GlFormInput,
    GlFormInputGroup,
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
    hasPathNavigation: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    const { hasPathNavigation, initialData } = this;
    const additionalFields = hasPathNavigation
      ? {
          selectedPreset: PRESET_OPTIONS[0].value,
          presetOptions: PRESET_OPTIONS,
          stages: DEFAULT_STAGE_CONFIG,
          ...initialData,
        }
      : {};
    return {
      name: '',
      errors: {},
      ...additionalFields,
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
    hiddenStages() {
      return this.stages.filter(stage => stage.hidden);
    },
    activeStages() {
      return this.stages.filter(stage => !stage.hidden);
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
    findPositionByIndex(index) {
      return this.stages.findIndex(stage => stage.index === index);
    },
    isFirstActiveStage(stageIndex) {
      const pos = this.findPositionByIndex(stageIndex);
      return pos === 0;
    },
    isLastActiveStage(stageIndex) {
      const pos = this.findPositionByIndex(stageIndex);
      return pos === this.activeStages?.length - 1;
    },
    onSubmit() {
      const { name, stages } = this;
      console.log('stages', this.stages);
      return this.createValueStream({ name, stages }).then(() => {
        if (!this.hasFormErrors) {
          this.$toast.show(sprintf(this.$options.I18N.CREATED, { name }), {
            position: 'top-center',
          });
          this.name = '';
          // reset the additional fields
        }
      });
    },
    handleMove(index, direction) {
      console.log('move', index, direction);
      const stage = this.stages[index];
      this.stages[index] = {
        ...stage,
        // TODO: should be camelCased, then converted later on
        move_after_id: direction === DIRECTION.DOWN ? index + 1 : null,
        move_before_id: direction === DIRECTION.UP ? index - 1 : null,
      };
    },
    onHide(index) {
      this.stages[index] = {
        ...this.stages[index],
        hidden: true,
      };
    },
  },
  I18N,
  DIRECTION,
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
      <div>
        <gl-form-group
          :label="$options.I18N.FIELD_NAME_LABEL"
          label-for="create-value-stream-name"
          :invalid-feedback="invalidFeedback"
          :state="isValid"
        >
          <gl-form-input-group>
            <gl-form-input
              id="create-value-stream-name"
              v-model.trim="name"
              name="create-value-stream-name"
              :placeholder="$options.I18N.FIELD_NAME_PLACEHOLDER"
              :state="isValid"
              required
              @input="onHandleInput"
            />
            <template v-if="hiddenStages.length" #append>
              <a href="">Restore defaults</a>
            </template>
          </gl-form-input-group>
        </gl-form-group>
      </div>
      <div v-if="hasPathNavigation">
        <hr />
        <div v-for="(stage, activeStageIndex) in activeStages" :key="stage.id">
          <gl-form-group
            v-if="!stage.hidden"
            :label="sprintf(__('Stage %{index}'), { index: activeStageIndex + 1 })"
          >
            <div class="gl-display-flex gl-flex-direction-row gl-justify-content-space-between">
              <div>
                <gl-form-input
                  v-if="stage.custom"
                  v-model.trim="stage.name"
                  :name="`create-value-stream-stage-${i}`"
                  :placeholder="s__('CreateValueStreamForm|Enter stage name')"
                  :state="isValid"
                  required
                  @input="onHandleInput"
                />
                <span v-else>{{ stage.name }}</span>
              </div>
              <div>
                <gl-button-group>
                  <gl-button
                    :disabled="isLastActiveStage(stage.index)"
                    icon="arrow-down"
                    @click="handleMove(stage.index, $options.DIRECTION.DOWN)"
                  />
                  <gl-button
                    :disabled="isFirstActiveStage(stage.index)"
                    icon="arrow-up"
                    @click="handleMove(stage.index, $options.DIRECTION.UP)"
                  />
                </gl-button-group>
                &nbsp;
                <gl-button icon="archive" @click="onHide(stage.index)" />
              </div>
            </div>
          </gl-form-group>
        </div>
        <div v-if="hiddenStages.length">
          <hr />
          <gl-form-group v-for="stage in hiddenStages" :key="stage.id">
            <label>{{ stage.name }} (default)</label>
            <!-- <span class="gl-font-size-base gl-font-weight-bold">{{ stage.name }} (default)</span> -->
            <a href="">Restore stage</a>
          </gl-form-group>
        </div>
      </div>
    </gl-form>
  </gl-modal>
</template>
