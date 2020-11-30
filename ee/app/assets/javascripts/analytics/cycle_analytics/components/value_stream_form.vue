<script>
import Vue from 'vue';
import { GlButton, GlButtonGroup, GlForm, GlFormInput, GlFormGroup, GlModal } from '@gitlab/ui';
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

const DEFAULT_STAGE_CONFIG = ['issue', 'plan', 'code', 'test', 'review', 'staging'].map(id => ({
  id,
  defaultName: capitalizeFirstCharacter(id),
  name: capitalizeFirstCharacter(id),
  custom: true,
  hidden: false,
}));

const SORT_DIRECTION = {
  UP: 'UP',
  DOWN: 'DOWN',
};

const swapArrayItems = (arr, left, right) => {
  // TODO: bounds checking
  return [...arr.slice(0, left), arr[right], arr[left], ...arr.slice(right + 1, arr.length)];
};

export default {
  name: 'ValueStreamForm',
  components: {
    GlButton,
    GlButtonGroup,
    GlForm,
    GlFormInput,
    GlFormGroup,
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
    // Forcing this to false until this is supported on the BE
    canReorderDefaults: {
      type: Boolean,
      required: false,
      default: true,
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
      return this.createValueStream({
        name,
        stages: stages.map(({ name: stageName, ...rest }) => ({
          name: stageName,
          ...rest,
          title: stageName,
        })),
      }).then(() => {
        if (!this.hasFormErrors) {
          this.$toast.show(sprintf(this.$options.I18N.CREATED, { name }), {
            position: 'top-center',
          });
          this.name = '';
        }
      });
    },
    handleMove({ index, direction }) {
      const newStages =
        direction === SORT_DIRECTION.UP
          ? swapArrayItems(this.stages, index - 1, index)
          : swapArrayItems(this.stages, index, index + 1);

      Vue.set(this, 'stages', newStages);
    },
    onSetHidden(index, hidden = true) {
      const stage = this.stages[index];
      Vue.set(this.stages, index, { ...stage, hidden });
    },
    handleReset() {
      this.name = '';
      DEFAULT_STAGE_CONFIG.forEach((stage, index) => {
        Vue.set(this.stages, index, { ...stage, hidden: false });
      });
    },
  },
  I18N,
  SORT_DIRECTION,
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
          <div class="gl-display-flex gl-justify-content-space-between">
            <gl-form-input
              id="create-value-stream-name"
              v-model.trim="name"
              name="create-value-stream-name"
              :placeholder="$options.I18N.FIELD_NAME_PLACEHOLDER"
              :state="isValid"
              required
              @input="onHandleInput"
            />
            <gl-button
              v-if="hiddenStages.length"
              class="gl-ml-3"
              variant="link"
              @click="handleReset"
              >{{ __('Restore defaults') }}</gl-button
            >
          </div>
        </gl-form-group>
      </div>
      <div v-if="hasPathNavigation">
        <hr />
        <div v-for="(stage, activeStageIndex) in activeStages" :key="activeStageIndex">
          <gl-form-group
            v-if="!stage.hidden"
            :label="sprintf(__('Stage %{index}'), { index: activeStageIndex + 1 })"
          >
            <div class="gl-display-flex gl-flex-direction-row gl-justify-content-space-between">
              <!-- v-if="stage.custom" -->
              <gl-form-input
                v-model.trim="stage.name"
                :name="`create-value-stream-stage-${activeStageIndex}`"
                :placeholder="s__('CreateValueStreamForm|Enter stage name')"
                :state="isValid"
                required
                @input="onHandleInput"
              />
              <!-- <span v-else>{{ stage.name }}</span> -->
              <gl-button-group v-if="canReorderDefaults" class="gl-px-2">
                <gl-button
                  :disabled="isLastActiveStage(activeStageIndex)"
                  icon="arrow-down"
                  @click="
                    handleMove({
                      index: activeStageIndex,
                      direction: $options.SORT_DIRECTION.DOWN,
                    })
                  "
                />
                <gl-button
                  :disabled="isFirstActiveStage(activeStageIndex)"
                  icon="arrow-up"
                  @click="
                    handleMove({ index: activeStageIndex, direction: $options.SORT_DIRECTION.UP })
                  "
                />
              </gl-button-group>
              <gl-button icon="archive" @click="onSetHidden(activeStageIndex)" />
            </div>
          </gl-form-group>
        </div>
        <div v-if="hiddenStages.length">
          <hr />
          <gl-form-group v-for="(stage, hiddenStageIndex) in hiddenStages" :key="stage.id">
            <label class="gl-m-0 gl-vertical-align-middle gl-mr-3"
              >{{ stage.name }} {{ __('(default)') }}</label
            >
            <!-- unhide and add to the end of the array -->
            <gl-button variant="link" @click="onRestore(hiddenStageIndex, false)">{{
              s__('CreateValueStreamForm|Restore stage')
            }}</gl-button>
          </gl-form-group>
        </div>
      </div>
    </gl-form>
  </gl-modal>
</template>
