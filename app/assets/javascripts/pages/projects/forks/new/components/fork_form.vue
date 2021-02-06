<script>
import {
  GlLoadingIcon,
  GlIcon,
  GlLink,
  GlForm,
  GlFormInputGroup,
  GlInputGroupText,
  GlFormInput,
  GlFormGroup,
  GlFormTextarea,
  GlButton,
  GlFormRadio,
  GlFormRadioGroup,
  GlFormSelect,
} from '@gitlab/ui';
import { __ } from '~/locale';
import csrf from '~/lib/utils/csrf';

export default {
  components: {
    GlForm,
    GlIcon,
    GlLink,
    GlButton,
    GlLoadingIcon,
    GlFormInputGroup,
    GlInputGroupText,
    GlFormInput,
    GlFormTextarea,
    GlFormGroup,
    GlFormRadio,
    GlFormRadioGroup,
    GlFormSelect,
  },
  props: {
    hasReachedProjectLimit: {
      type: Boolean,
      required: true,
    },
    endpoint: {
      type: String,
      required: true,
    },
    newGroupPath: {
      type: String,
      required: true,
    },
    projectName: {
      type: String,
      required: true,
    },
    projectPath: {
      type: String,
      required: true,
    },
    projectDescription: {
      type: String,
      required: true,
    },
    projectVisibility: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      forkProjectName: this.projectName,
      forkProjectUrl: '',
      forkProjectSlug: '',
      forkProjectDescription: this.projectDescription,
      forkVisibilityLevel: this.projectVisibility,
    };
  },
  computed: {},
  csrf,
  forkVisibilityLevelOptions: [
    {
      text: __('Private'),
      value: 'private',
      icon: 'lock',
      help: __('The project can be accessed without any authentication.'),
    },
    {
      text: __('Public'),
      value: 'public',
      icon: 'earth',
      help: __(
        'Project access must be granted explicitly to each user. If this project is part of a group, access will be granted to members of the group.',
      ),
    },
  ],
  projectUrlOptions: ['one', 'two'],
};
</script>

<template>
  <gl-form method="POST">
    <input type="hidden" name="authenticity_token" :value="$options.csrf.token" />

    <gl-form-group label="Project name" label-for="fork-project-name">
      <gl-form-input v-model="forkProjectName" id="fork-project-name" />
    </gl-form-group>

    <div class="gl-display-flex">
      <div class="gl-w-half">
        <gl-form-group label="Project URL" label-for="fork-project-url" class="pr-2">
          <gl-form-input-group>
            <template #prepend>
              <gl-input-group-text>
                {{ __('https://gitlab.com/') }}
              </gl-input-group-text>
            </template>
            <gl-form-select v-model="forkProjectUrl" :options="$options.projectUrlOptions" />
          </gl-form-input-group>
        </gl-form-group>
      </div>
      <div class="gl-w-half">
        <gl-form-group label="Project slug" label-for="fork-project-slug" class="pl-2">
          <gl-form-input v-model="forkProjectSlug" id="fork-project-url" />
        </gl-form-group>
      </div>
    </div>

    <p class="gl-mt-n5 gl-text-gray-500">
      {{ __('Want to house several dependent projects under the same namespace?') }}
      <gl-link :href="newGroupPath" target="_blank">
        {{ __('Create a group') }}
      </gl-link>
    </p>

    <gl-form-group label="Project description (optional)" label-for="fork-project-description">
      <gl-form-textarea id="fork-project-description" />
    </gl-form-group>

    <gl-form-group label="Project description (optional)" label-for="fork-project-description">
      <gl-form-textarea v-model="forkProjectDescription" id="fork-project-description" />
    </gl-form-group>

    <!-- if we use "name", must match with BE name ex. name="prometheus_metric[group]" -->
    <gl-form-group
      :label="__('Visibility Level')"
      label-for="prometheus_metric_group"
      label-class="label-bold"
    >
      <gl-form-radio-group v-model="forkVisibilityLevel">
        <gl-form-radio
          v-for="{ text, value, icon, help } in $options.forkVisibilityLevelOptions"
          :key="value"
          :value="value"
        >
          <div>
            <gl-icon :name="icon" />
            <span>{{ text }}</span>
          </div>
          <template #help>{{ help }}</template>
        </gl-form-radio>
      </gl-form-radio-group>
    </gl-form-group>
  </gl-form>
</template>
