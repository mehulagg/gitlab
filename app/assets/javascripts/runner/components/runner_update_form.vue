<script>
import {
  GlButton,
  GlForm,
  GlFormCheckbox,
  GlFormGroup,
  GlFormInputGroup,
  GlTooltipDirective,
} from '@gitlab/ui';
import { ACCESS_LEVEL_NOT_PROTECTED, ACCESS_LEVEL_REF_PROTECTED, PROJECT_TYPE } from '../constants';

export default {
  components: {
    GlButton,
    GlForm,
    GlFormCheckbox,
    GlFormGroup,
    GlFormInputGroup,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    runner: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      model: { ...this.runner },
    };
  },
  computed: {
    isLockedAvailable() {
      return this.runner.runnerType === PROJECT_TYPE;
    },
    tags() {
      return this.model.tagList?.join(', ');
    },
  },
  watch: {
    runner() {
      // TODO Check if this can be better
      this.model = { ...this.runner };
    },
  },
  methods: {
    onSubmit() {
      console.log('Submitting', this.model);
    },
    onTagsInput($event) {
      this.model.tagList = $event.split(',').map((tag) => tag.trim());
    },
  },
  ACCESS_LEVEL_NOT_PROTECTED,
  ACCESS_LEVEL_REF_PROTECTED,
};
</script>
<template>
  <gl-form @submit.prevent="onSubmit">
    <!-- <pre>
runner:
{{ runner }}
model:
{{ model }}
</pre
    > -->
    <gl-form-checkbox v-model="model.active" :value="false" :unchecked-value="true">
      {{ __('Paused') }}
      <template #help>
        {{ __("Paused runners don't accept new jobs") }}
      </template>
    </gl-form-checkbox>

    <gl-form-checkbox
      v-model="model.accessLevel"
      :value="$options.ACCESS_LEVEL_REF_PROTECTED"
      :unchecked-value="$options.ACCESS_LEVEL_NOT_PROTECTED"
    >
      {{ __('Protected') }}
      <template #help>
        {{ __('This runner will only run on pipelines triggered on protected branches') }}
      </template>
    </gl-form-checkbox>

    <gl-form-checkbox v-model="model.runUntagged">
      {{ __('Run untagged jobs') }}
      <template #help>
        {{ __('Indicates whether this runner can pick jobs without tags') }}
      </template>
    </gl-form-checkbox>

    <gl-form-checkbox v-model="model.locked" :disabled="isLockedAvailable">
      {{ __('Lock to current projects') }}
      <template #help>
        {{ __('When a runner is locked, it cannot be assigned to other projects') }}
      </template>
    </gl-form-checkbox>

    <gl-form-group id="ip-address" :label="__('IP Address')" label-for="ip-address">
      <gl-form-input-group :value="model.ipAddress" readonly select-on-click>
        <template #append>
          <gl-button
            v-gl-tooltip.hover
            :title="__('Copy IP Address')"
            :aria-label="__('Copy IP Address')"
            :data-clipboard-text="model.ipAddress"
            icon="copy-to-clipboard"
            class="d-inline-flex"
          />
        </template>
      </gl-form-input-group>
    </gl-form-group>

    <gl-form-group id="description" :label="__('Description')" label-for="description">
      <gl-form-input-group v-model="model.description" />
    </gl-form-group>

    <gl-form-group
      id="max-job-timeout"
      :label="__('Maximum job timeout')"
      label-for="max-job-timeout"
      :description="
        __(
          'Enter the number of seconds. This timeout takes precedence over lower timeouts set for the project.',
        )
      "
    >
      <gl-form-input-group v-model.number="model.maximumTimeout" type="number" />
    </gl-form-group>

    <gl-form-group
      id="tags"
      :label="__('Tags')"
      label-for="tags"
      :description="
        __('You can set up jobs to only use runners with specific tags. Separate tags with commas.')
      "
    >
      <gl-form-input-group :value="tags" @input="onTagsInput" />
    </gl-form-group>

    <div class="form-actions">
      <gl-button type="submit">{{ __('Save changes') }}</gl-button>
    </div>
  </gl-form>
</template>
