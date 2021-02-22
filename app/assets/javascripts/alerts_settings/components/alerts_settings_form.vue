<script>
  import {
    GlButton,
    GlCollapse,
    GlForm,
    GlFormGroup,
    GlFormSelect,
    GlFormInput,
    GlFormInputGroup,
    GlFormTextarea,
    GlModal,
    GlModalDirective,
    GlToggle,
    GlTabs,
    GlTab,
  } from '@gitlab/ui';
  import * as Sentry from '@sentry/browser';
  import {isEmpty, omit} from 'lodash';
  import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';
  import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
  import {
    integrationTypes,
    JSON_VALIDATE_DELAY,
    targetPrometheusUrlPlaceholder,
    typeSet,
    i18n,
  } from '../constants';
  import getCurrentIntegrationQuery from '../graphql/queries/get_current_integration.query.graphql';
  import parseSamplePayload from '../graphql/queries/parse_sample_payload.query.graphql';
  import MappingBuilder from './alert_mapping_builder.vue';
  import AlertSettingsFormHelpBlock from './alert_settings_form_help_block.vue';

  export default {
    placeholders: {
      prometheus: targetPrometheusUrlPlaceholder,
    },
    JSON_VALIDATE_DELAY,
    typeSet,
    i18n,
    components: {
      ClipboardButton,
      GlButton,
      GlCollapse,
      GlForm,
      GlFormGroup,
      GlFormInput,
      GlFormInputGroup,
      GlFormTextarea,
      GlFormSelect,
      GlModal,
      GlToggle,
      GlTabs,
      GlTab,
      AlertSettingsFormHelpBlock,
      MappingBuilder,
    },
    directives: {
      GlModal: GlModalDirective,
    },
    mixins: [glFeatureFlagsMixin()],
    inject: {
      generic: {
        default: {},
      },
      prometheus: {
        default: {},
      },
      multiIntegrations: {
        default: false,
      },
      projectPath: {
        default: '',
      },
    },
    props: {
      loading: {
        type: Boolean,
        required: true,
      },
      canAddIntegration: {
        type: Boolean,
        required: true,
      },
      alertFields: {
        type: Array,
        required: false,
        default: null,
      },
    },
    apollo: {
      currentIntegration: {
        query: getCurrentIntegrationQuery,
      },
    },
    data() {
      return {
        integrationTypesOptions: Object.values(integrationTypes),
        selectedIntegration: integrationTypes.none.value,
        active: false,
        integrationTestPayload: {
          json: null,
          error: null,
        },
        resetPayloadAndMappingConfirmed: false,
        mapping: [],
        parsingPayload: false,
        currentIntegration: null,
        parsedPayload: [],
      };
    },
    computed: {
      isPrometheus() {
        return this.selectedIntegration === this.$options.typeSet.prometheus;
      },
      jsonIsValid() {
        return this.integrationTestPayload.error === null;
      },
      selectedIntegrationType() {
        switch (this.selectedIntegration) {
          case typeSet.http:
            return this.generic;
          case typeSet.prometheus:
            return this.prometheus;
          default:
            return {};
        }
      },
      integrationForm() {
        return {
          name: this.currentIntegration?.name || '',
          active: this.currentIntegration?.active || false,
          token:
            this.currentIntegration?.token ||
            (this.selectedIntegrationType !== this.generic ? this.selectedIntegrationType.token : ''),
          url:
            this.currentIntegration?.url ||
            (this.selectedIntegrationType !== this.generic ? this.selectedIntegrationType.url : ''),
          apiUrl: this.currentIntegration?.apiUrl || '',
        };
      },
      testAlertPayload() {
        return {
          data: this.integrationTestPayload.json,
          endpoint: this.integrationForm.url,
          token: this.integrationForm.token,
        };
      },
      showMappingBuilder() {
        return (
          this.multiIntegrations &&
          this.glFeatures.multipleHttpIntegrationsCustomMapping &&
          this.selectedIntegration === typeSet.http &&
          this.alertFields?.length
        );
      },
      hasSamplePayload() {
        return this.isValidNonEmptyJSON(this.currentIntegration?.payloadExample);
      },
      canEditPayload() {
        return this.hasSamplePayload && !this.resetPayloadAndMappingConfirmed;
      },
      isResetAuthKeyDisabled() {
        return !this.active && !this.integrationForm.token !== '';
      },
      isPayloadEditDisabled() {
        return this.glFeatures.multipleHttpIntegrationsCustomMapping
          ? !this.active || this.canEditPayload
          : !this.active;
      },
      isSubmitTestPayloadDisabled() {
        return (
          !this.active ||
          Boolean(this.integrationTestPayload.error) ||
          this.integrationTestPayload.json === ''
        );
      },
      isSelectDisabled() {
        return this.currentIntegration !== null || !this.canAddIntegration;
      },
      savedMapping() {
        return this.mapping;
      },
    },
    watch: {
      currentIntegration(val) {
        if (val === null) {
          this.reset();
          return;
        }
        const {type, active, payloadExample, payloadAlertFields, payloadAttributeMappings} = val;
        this.selectedIntegration = type;
        this.active = active;

        if (type === typeSet.prometheus) {
          this.integrationTestPayload.json = null;
        }

        if (type === typeSet.http && this.showMappingBuilder) {
          this.parsedPayload = payloadAlertFields;
          this.integrationTestPayload.json = this.isValidNonEmptyJSON(payloadExample)
            ? payloadExample
            : null;
          const mapping = payloadAttributeMappings.map((m) => omit(m, '__typename'));
          this.updateMapping(mapping);
        }
      },
    },
    methods: {
      isValidNonEmptyJSON(JSONString) {
        if (JSONString) {
          let parsed;
          try {
            parsed = JSON.parse(JSONString);
          } catch (error) {
            Sentry.captureException(error);
          }
          if (parsed) return !isEmpty(parsed);
        }
        return false;
      },
      submitWithTestPayload() {
        this.$emit('set-test-alert-payload', this.testAlertPayload);
        this.submit();
      },
      submit() {
        const {name, apiUrl} = this.integrationForm;
        const customMappingVariables = this.glFeatures.multipleHttpIntegrationsCustomMapping
          ? {
            payloadAttributeMappings: this.mapping,
            payloadExample: this.integrationTestPayload.json || '{}',
          }
          : {};

        const variables =
          this.selectedIntegration === typeSet.http
            ? {name, active: this.active, ...customMappingVariables}
            : {apiUrl, active: this.active};
        const integrationPayload = {type: this.selectedIntegration, variables};
        if (this.currentIntegration) {
          return this.$emit('update-integration', integrationPayload);
        }

        this.reset();
        return this.$emit('create-new-integration', integrationPayload);
      },
      reset() {
        this.selectedIntegration = integrationTypes.none.value;
        this.resetPayloadAndMapping();

        if (this.currentIntegration) {
          return this.$emit('clear-current-integration', {type: this.currentIntegration.type});
        }

        return this.resetFormValues();
      },
      resetFormValues() {
        this.integrationForm.name = '';
        this.integrationForm.apiUrl = '';
        this.integrationTestPayload = {
          json: null,
          error: null,
        };
        this.active = false;
      },
      resetAuthKey() {
        if (!this.currentIntegration) {
          return;
        }

        this.$emit('reset-token', {
          type: this.selectedIntegration,
          variables: {id: this.currentIntegration.id},
        });
      },
      validateJson() {
        this.integrationTestPayload.error = null;
        if (this.integrationTestPayload.json === '') {
          return;
        }

        try {
          JSON.parse(this.integrationTestPayload.json);
        } catch (e) {
          this.integrationTestPayload.error = JSON.stringify(e.message);
        }
      },
      parseMapping() {
        this.parsingPayload = true;

        return this.$apollo
          .query({
            query: parseSamplePayload,
            variables: {projectPath: this.projectPath, payload: this.integrationTestPayload.json},
          })
          .then(
            ({
               data: {
                 project: {alertManagementPayloadFields},
               },
             }) => {
              this.parsedPayload = alertManagementPayloadFields;
              this.resetPayloadAndMappingConfirmed = false;

              this.$toast.show(this.$options.i18n.integrationFormSteps.step4.payloadParsedSucessMsg);
            },
          )
          .catch(({message}) => {
            this.integrationTestPayload.error = message;
          })
          .finally(() => {
            this.parsingPayload = false;
          });
      },
      updateMapping(mapping) {
        this.mapping = mapping;
      },
      resetPayloadAndMapping() {
        this.resetPayloadAndMappingConfirmed = true;
        this.parsedPayload = [];
        this.updateMapping([]);
      },
    },
  };
</script>

<template>
  <gl-form class="gl-mt-6" @submit.prevent="submit" @reset.prevent="reset">
    <gl-tabs>
      <gl-tab :title="$options.i18n.integrationTabs.configureDetails">
        <gl-form-group
          id="integration-type"
          :label="$options.i18n.integrationFormSteps.step1.label"
          label-for="integration-type"
        >
          <gl-form-select
            v-model="selectedIntegration"
            :disabled="isSelectDisabled"
            class="gl-max-w-full"
            :options="integrationTypesOptions"
          />

          <alert-settings-form-help-block
            v-if="!canAddIntegration" class="gl-display-inline-block gl-my-4"
            data-testid="multi-integrations-not-supported"
            :message="$options.i18n.integrationFormSteps.step1.enterprise"
            link="https://about.gitlab.com/pricing"
          />
        </gl-form-group>
        <div class="gl-mt-3">
          <gl-form-group
            id="name-integration"
            :label="$options.i18n.integrationFormSteps.step2.label"
            label-for="name-integration"
          >
            <gl-form-input
              v-model="integrationForm.name"
              :disabled="isPrometheus"
              type="text"
              :placeholder="
              isPrometheus
                ? $options.i18n.integrationFormSteps.step2.prometheus
                : $options.i18n.integrationFormSteps.step2.placeholder
            "
            />
          </gl-form-group>

          <alert-settings-form-help-block
            :message="
              isPrometheus
                ? $options.i18n.integrationFormSteps.step3.prometheusHelp
                : $options.i18n.integrationFormSteps.step3.help
            "
            link="https://docs.gitlab.com/ee/operations/incident_management/alert_integrations.html"
          />

          <gl-toggle
            v-model="active"
            :is-loading="loading"
            :label="__('Active')"
            class="gl-my-4 gl-font-weight-normal"
          />


          <div v-if="isPrometheus" class="gl-my-4">
              <span class="gl-font-weight-bold">
                {{ $options.i18n.integrationFormSteps.prometheusFormUrl.label }}
              </span>

            <gl-form-input
              id="integration-apiUrl"
              v-model="integrationForm.apiUrl"
              type="text"
              :placeholder="$options.placeholders.prometheus"
            />

            <span class="gl-text-gray-400">
                {{ $options.i18n.integrationFormSteps.prometheusFormUrl.help }}
              </span>
          </div>

          <gl-form-group
            id="test-integration"
            :label="$options.i18n.integrationFormSteps.step4.label"
            label-for="test-integration"
            :class="{ 'gl-mb-0!': showMappingBuilder }"
            :invalid-feedback="integrationTestPayload.error"
          >
            <alert-settings-form-help-block
              :message="
              isPrometheus || !showMappingBuilder
                ? $options.i18n.integrationFormSteps.step4.prometheusHelp
                : $options.i18n.integrationFormSteps.step4.help
            "
              :link="generic.alertsUsageUrl"
            />

            <gl-form-textarea
              id="test-payload"
              v-model.trim="integrationTestPayload.json"
              :disabled="isPayloadEditDisabled"
              :state="jsonIsValid"
              :placeholder="$options.i18n.integrationFormSteps.step4.placeholder"
              class="gl-my-3"
              :debounce="$options.JSON_VALIDATE_DELAY"
              rows="6"
              max-rows="10"
              @input="validateJson"
            />
          </gl-form-group>

          <template v-if="showMappingBuilder">
            <gl-button
              v-if="canEditPayload"
              v-gl-modal.resetPayloadModal
              data-testid="payload-action-btn"
              :disabled="!active"
              class="gl-mt-3"
            >
              {{ $options.i18n.integrationFormSteps.step4.editPayload }}
            </gl-button>

            <gl-button
              v-else
              data-testid="payload-action-btn"
              :class="{ 'gl-mt-3': integrationTestPayload.error }"
              :disabled="!active"
              :loading="parsingPayload"
              @click="parseMapping"
            >
              {{ $options.i18n.integrationFormSteps.step4.submitPayload }}
            </gl-button>
            <gl-modal
              modal-id="resetPayloadModal"
              :title="$options.i18n.integrationFormSteps.step4.resetHeader"
              :ok-title="$options.i18n.integrationFormSteps.step4.resetOk"
              ok-variant="danger"
              @ok="resetPayloadAndMapping"
            >
              {{ $options.i18n.integrationFormSteps.step4.resetBody }}
            </gl-modal>
          </template>

          <gl-form-group
            v-if="showMappingBuilder"
            id="mapping-builder"
            class="gl-mt-5"
            :label="$options.i18n.integrationFormSteps.step5.label"
            label-for="mapping-builder"
          >
            <span>{{ $options.i18n.integrationFormSteps.step5.intro }}</span>
            <mapping-builder
              :parsed-payload="parsedPayload"
              :saved-mapping="savedMapping"
              :alert-fields="alertFields"
              @onMappingUpdate="updateMapping"
            />
          </gl-form-group>
        </div>

        <div class="gl-display-flex gl-justify-content-start gl-py-3">
          <gl-button
            type="submit"
            variant="confirm"
            class="js-no-auto-disable"
            data-testid="integration-form-submit"
          >{{ s__('AlertSettings|Save integration') }}
          </gl-button>
          <!--          <gl-button-->
          <!--            data-testid="integration-test-and-submit"-->
          <!--            :disabled="isSubmitTestPayloadDisabled"-->
          <!--            category="secondary"-->
          <!--            variant="success"-->
          <!--            class="gl-mx-3 js-no-auto-disable"-->
          <!--            @click="submitWithTestPayload"-->
          <!--          >{{ s__('AlertSettings|Save and test payload') }}-->
          <!--          </gl-button-->

          <gl-button type="reset" class="js-no-auto-disable">{{ __('Cancel and close') }}</gl-button>
        </div>
      </gl-tab>

      <gl-tab :title="$options.i18n.integrationTabs.viewCredentials">

        <gl-form-group
          id="integration-webhook">

          <div class="gl-my-4">
            <span class="gl-font-weight-bold">
              {{ s__('AlertSettings|Webhook URL') }}
            </span>

            <gl-form-input-group id="url" readonly :value="integrationForm.url">
              <template #append>
                <clipboard-button
                  :text="integrationForm.url || ''"
                  :title="__('Copy')"
                  class="gl-m-0!"
                />
              </template>
            </gl-form-input-group>
          </div>

          <div class="gl-my-4">
            <span class="gl-font-weight-bold">
              {{ $options.i18n.integrationFormSteps.step3.info }}
            </span>

            <gl-form-input-group
              id="authorization-key"
              class="gl-mb-3"
              readonly
              :value="integrationForm.token"
            >
              <template #append>
                <clipboard-button
                  :text="integrationForm.token || ''"
                  :title="__('Copy')"
                  class="gl-m-0!"
                />
              </template>
            </gl-form-input-group>

            <gl-button v-gl-modal.authKeyModal :disabled="isResetAuthKeyDisabled">
              {{ $options.i18n.integrationFormSteps.step3.reset }}
            </gl-button>
            <gl-modal
              modal-id="authKeyModal"
              :title="$options.i18n.integrationFormSteps.step3.reset"
              :ok-title="$options.i18n.integrationFormSteps.step3.reset"
              ok-variant="danger"
              @ok="resetAuthKey"
            >
              {{ $options.i18n.integrationFormSteps.restKeyInfo.label }}
            </gl-modal>
          </div>
        </gl-form-group>
      </gl-tab>

      <gl-tab :title="$options.i18n.integrationTabs.sendTestAlert">
      </gl-tab>

    </gl-tabs>

  </gl-form>
</template>
