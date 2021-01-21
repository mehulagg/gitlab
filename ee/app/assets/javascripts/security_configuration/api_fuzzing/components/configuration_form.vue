<script>
import { GlFormGroup, GlFormText, GlFormCheckbox, GlSprintf } from '@gitlab/ui';
import { s__ } from '~/locale';
import DynamicFields from '../../components/dynamic_fields.vue';
import ExpandableSection from '../../components/expandable_section.vue';
import FormInput from '../../components/form_input.vue';

export default {
  components: {
    GlFormGroup,
    GlFormText,
    GlFormCheckbox,
    GlSprintf,
    DynamicFields,
    ExpandableSection,
    FormInput,
  },
  props: {
    apiFuzzingCiConfiguration: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      baseSettings: [
        {
          type: 'string',
          field: 'targetUrl',
          label: s__('APIFuzzing|Target URL'),
          description: s__('APIFuzzing|Base URL of API fuzzing target.'),
          value: '',
        },
        {
          type: 'select',
          field: 'scanMode',
          label: s__('APIFuzzing|Scan mode'),
          description: s__('APIFuzzing|There are three ways to perform scans.'),
          value: '',
          defaultText: s__('APIFuzzing|Choose a method'),
          options: [
            {
              value: 'har',
              text: s__('APIFuzzing|HAR (HTTP Archive)'),
            },
          ],
        },
      ],
      apiSpecificationFile: '',
      authenticationEnabled: false,
      authenticationSettings: [
        {
          type: 'string',
          field: 'username',
          label: s__('APIFuzzing|Username for basic authentication.'),
          description: '',
          value: '',
        },
        {
          type: 'string',
          field: 'password',
          label: s__('APIFuzzing|Password for basic authentication.'),
          description: '',
          value: '',
        },
      ],
      advancedSettings: [
        {
          type: 'select',
          field: 'scanProfile',
          label: s__('APIFuzzing|Scan profile'),
          description: 'Pre-defined profiles by GitLab.',
          value: '',
          defaultText: s__('APIFuzzing|Choose a profile'),
          options: [
            {
              value: 'profile1',
              text: 'profile1',
            },
          ],
        },
      ],
    };
  },
  computed: {
    isScanModeSelected() {
      return Boolean(this.baseSettings.find(({ field }) => field === 'scanMode').value);
    },
  },
  methods: {
    onSubmit() {},
  },
};
</script>

<template>
  <form @submit.prevent="onSubmit">
    <dynamic-fields v-model="baseSettings" />

    <form-input
      v-if="isScanModeSelected"
      v-model="apiSpecificationFile"
      :label="__('HAR file')"
      :description="
        s__(
          'APIFuzzing|HAR files may contain sensitive information such as authentication tokens, API keys, and session cookies. We recommend that you review the HAR files\' contents before adding them to a repository.',
        )
      "
    />

    <gl-form-group>
      <template #label>
        {{ __('Authentication') }}
        <gl-form-text class="gl-mt-3">
          <gl-sprintf
            :message="
              s__(
                'APIFuzzing|Authentication is handled by providing HTTP basic authentication token as a header or cookie. %{linkStart}More information%{linkEnd}.',
              )
            "
          >
            <template #link="{ content }">
              <a href="#">
                <!-- TODO: need real link -->
                {{ content }}
              </a>
            </template>
          </gl-sprintf>
        </gl-form-text>
      </template>
      <gl-form-checkbox v-model="authenticationEnabled">
        {{ s__('APIFuzzing|Enable authentication') }}
      </gl-form-checkbox>
    </gl-form-group>

    <dynamic-fields v-if="authenticationEnabled" v-model="authenticationSettings" />

    <expandable-section>
      <template #heading>{{ __('Advanced') }}</template>
      <dynamic-fields v-model="advancedSettings" />
    </expandable-section>
  </form>
</template>
