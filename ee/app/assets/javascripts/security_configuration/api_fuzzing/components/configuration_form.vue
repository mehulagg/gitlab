<script>
import {
  GlAccordion,
  GlAccordionItem,
  GlAlert,
  GlButton,
  GlFormGroup,
  GlFormText,
  GlFormCheckbox,
  GlLink,
  GlSprintf,
} from '@gitlab/ui';
import { __, s__ } from '~/locale';
import DropdownInput from '../../components/dropdown_input.vue';
import DynamicFields from '../../components/dynamic_fields.vue';
import FormInput from '../../components/form_input.vue';

const SCAN_MODES = {
  HAR: {
    scanModeLabel: __('HAR (HTTP Archive)'),
    label: __('HAR file path'),
    placeholder: s__('APIFuzzing|Ex: Project_Test/File/example_fuzz.har'),
    description: s__(
      "APIFuzzing|HAR files may contain sensitive information such as authentication tokens, API keys, and session cookies. We recommend that you review the HAR files' contents before adding them to a repository.",
    ),
  },
  OPENAPI: {
    scanModeLabel: __('Open API'),
    label: __('Open API specification file path'),
    placeholder: s__('APIFuzzing|Ex: Project_Test/File/example_fuzz.json'),
    description: s__(
      'APIFuzzing|We recommend that you review the JSON specifications file before adding it to a repository.',
    ),
  },
};

export default {
  components: {
    GlAccordion,
    GlAccordionItem,
    GlAlert,
    GlButton,
    GlFormGroup,
    GlFormText,
    GlFormCheckbox,
    GlLink,
    GlSprintf,
    DropdownInput,
    DynamicFields,
    FormInput,
  },
  inject: {
    apiFuzzingAuthenticationDocumentationPath: {
      from: 'apiFuzzingAuthenticationDocumentationPath',
    },
    ciVariablesDocumentationPath: {
      from: 'ciVariablesDocumentationPath',
    },
    projectCiSettingsPath: {
      from: 'projectCiSettingsPath',
    },
    canSetProjectCiVariables: {
      from: 'canSetProjectCiVariables',
    },
  },
  props: {
    apiFuzzingCiConfiguration: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      targetUrl: {
        field: 'targetUrl',
        label: s__('APIFuzzing|Target URL'),
        description: s__('APIFuzzing|Base URL of API fuzzing target.'),
        placeholder: __('Ex: Example.com'),
        value: '',
      },
      scanMode: {
        field: 'scanMode',
        label: s__('APIFuzzing|Scan mode'),
        description: s__('APIFuzzing|There are two ways to perform scans.'),
        value: '',
        defaultText: s__('APIFuzzing|Choose a method'),
        options: this.apiFuzzingCiConfiguration.scanModes.map((value) => ({
          value,
          text: SCAN_MODES[value].scanModeLabel,
        })),
      },
      apiSpecificationFile: {
        field: 'apiSpecificationFile',
        value: '',
      },
      authenticationEnabled: false,
      authenticationSettings: [
        {
          type: 'string',
          field: 'username',
          label: s__('APIFuzzing|Username for basic authentication'),
          description: s__(
            'APIFuzzing|Instead of entering the username directly, enter the key of the CI variable set to the username.',
          ),
          placeholder: s__('APIFuzzing|Ex: $TestUsername'),
          value: '',
        },
        {
          type: 'string',
          field: 'password',
          label: s__('APIFuzzing|Password for basic authentication'),
          description: s__(
            'APIFuzzing|Instead of entering the password directly, enter the key of the CI variable set to the password.',
          ),
          placeholder: s__('APIFuzzing|Ex: $TestPassword'),
          value: '',
        },
      ],
      scanProfile: {
        field: 'scanProfile',
        label: s__('APIFuzzing|Scan profile'),
        description: 'Pre-defined profiles by GitLab.',
        value: '',
        defaultText: s__('APIFuzzing|Choose a profile'),
        options: this.apiFuzzingCiConfiguration.scanProfiles.map(
          ({ name: value, description: text }) => ({
            value,
            text,
          }),
        ),
      },
    };
  },
  computed: {
    authAlertI18n() {
      return this.canSetProjectCiVariables
        ? {
            title: s__('APIFuzzing|Make sure your credentials are secured'),
            text: s__(
              `APIFuzzing|To prevent a security leak, authentication info must be added as a
              %{ciVariablesLinkStart}CI variable%{ciVariablesLinkEnd}. As a user with maintainer access
              rights, you can manage CI variables in the
              %{ciSettingsLinkStart}Settings%{ciSettingsLinkEnd} area.`,
            ),
          }
        : {
            title: s__("APIFuzzing|You may need a maintainer's help to secure your credentials."),
            text: s__(
              `APIFuzzing|To prevent a security leak, authentication info must be added as a
              %{ciVariablesLinkStart}CI variable%{ciVariablesLinkEnd}. A user with maintainer
              access rights can manage CI variables in the
              %{ciSettingsLinkStart}Settings%{ciSettingsLinkEnd} area. We detected that you are not
              a maintainer. Commit your changes and assign them to a maintainer to update the
              credentials before merging.`,
            ),
          };
    },
    scanProfileYaml() {
      return this.apiFuzzingCiConfiguration.scanProfiles.find(
        ({ name }) => name === this.scanProfile.value,
      )?.yaml;
    },
  },
  methods: {
    onSubmit() {},
  },
  SCAN_MODES,
};
</script>

<template>
  <form @submit.prevent="onSubmit">
    <form-input v-model="targetUrl.value" v-bind="targetUrl" class="gl-mb-7" />

    <dropdown-input v-model="scanMode.value" v-bind="scanMode" />
    <form-input
      v-if="scanMode.value"
      v-model="apiSpecificationFile.value"
      v-bind="{ ...apiSpecificationFile, ...$options.SCAN_MODES[scanMode.value] }"
    />

    <gl-form-group class="gl-my-7">
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
              <a :href="apiFuzzingAuthenticationDocumentationPath">
                {{ content }}
              </a>
            </template>
          </gl-sprintf>
        </gl-form-text>
      </template>
      <gl-form-checkbox
        v-model="authenticationEnabled"
        data-testid="api-fuzzing-enable-authentication-checkbox"
      >
        {{ s__('APIFuzzing|Enable authentication') }}
      </gl-form-checkbox>
    </gl-form-group>

    <template v-if="authenticationEnabled">
      <gl-alert
        :title="authAlertI18n.title"
        :dismissible="false"
        variant="warning"
        class="gl-mb-5"
        data-testid="api-fuzzing-authentication-notice"
      >
        <gl-sprintf :message="authAlertI18n.text">
          <template #ciVariablesLink="{ content }">
            <gl-link :href="ciVariablesDocumentationPath" target="_blank">
              {{ content }}
            </gl-link>
          </template>
          <template #ciSettingsLink="{ content }">
            <gl-link :href="projectCiSettingsPath" target="_blank">
              {{ content }}
            </gl-link>
          </template>
        </gl-sprintf>
      </gl-alert>
      <dynamic-fields v-model="authenticationSettings" />
    </template>

    <dropdown-input v-model="scanProfile.value" v-bind="scanProfile" />
    <template v-if="scanProfileYaml">
      <gl-accordion>
        <gl-accordion-item :title="s__('APIFuzzing|Show code snippet for the profile')">
          <pre data-testid="api-fuzzing-scan-profile-yaml-viewer">{{ scanProfileYaml }}</pre>
        </gl-accordion-item>
      </gl-accordion>
    </template>

    <hr />

    <gl-button type="submit" variant="confirm">{{
      s__('APIFuzzing|Generate code snippet')
    }}</gl-button>
    <gl-button>{{ __('Cancel') }}</gl-button>
  </form>
</template>
