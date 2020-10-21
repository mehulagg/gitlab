<script>
  import {__} from '~/locale';
  import {
    GlTabs,
    GlTab,
    GlPath,
    GlFormTextarea,
    GlButton,
    GlFormGroup,
    GlFormInput,
    GlDropdown,
    GlDropdownItem,
  } from '@gitlab/ui';
  import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
  import {flattenObject} from "../utils";

  import {i18n} from '../constants';

  export default {
    i18n,
    items: [
      {
        title: __('Select Type (Custom)'),
        step: 'select',
      },
      {
        title: __('Configure'),
        step: 'configure',
        selected: true,
      },
      {
        title: __('Finalize'),
        step: 'finalize',
      },
    ],
    components: {
      GlTabs,
      GlTab,
      GlPath,
      GlFormTextarea,
      GlButton,
      GlFormGroup,
      GlFormInput,
      GlDropdown,
      GlDropdownItem,
    },
    mixins: [glFeatureFlagsMixin()],
    props: {},

    data() {
      return {
        activeStep: this.$options.items[1].step,
        testAlert: null,
        gitlabFields: [
          {
            key: 'title',
            title: __('Title (Text)'),
            mapping: null,
          },
          {
            key: 'startDate',
            title: __('Start time (Date)'),
            mapping: null,
          },
          {
            key: 'severity',
            title: __('Severity (Text)'),
            mapping: null,
          }
        ],
        mappingKeys: null,
      };
    },
    computed: {},
    methods: {
      setActiveStep(path) {
        this.activeStep = path.step;
      },
      parseTestAlert() {
        let parsed;
        try {
          parsed = JSON.parse(this.testAlert);
          this.mappingKeys = Object.keys(flattenObject(parsed));
          this.activeStep = 'finalize'
        } catch (e) {
          console.log('Invalid JSON');
        }
      },
      selectMapping(gitlabFieldKey, mappignKey) {
        const fieldToMap = this.gitlabFields.find(field => field.key === gitlabFieldKey);
        this.$set(fieldToMap, 'mapping', mappignKey)
      },
    },
  };
</script>

<template>
  <div class="mapping">
    <div class="gl-display-inline-flex gl-justify-content-space-between gl-flex-direction-row">
      <h5>Gitlab alert key</h5>
      <h5>Payload alert key</h5>
      <h5>Define substitute</h5>
    </div>
    <div v-for="gitlabField in gitlabFields"
         class="mapping-row gl-mb-5 gl-display-inline-flex gl-justify-content-space-between gl-flex-direction-row">
      <gl-form-input disabled :value="gitlabField.title" class="gl-display-inline-flex" style="width: 200px;"/>
      <gl-dropdown :text="gitlabField.mapping || __('Select mapping')"
                   style="width: 200px;">
        <gl-dropdown-item v-for="mappingKey in mappingKeys"
                          @click="selectMapping(gitlabField.key, mappingKey)">
          {{mappingKey}}
        </gl-dropdown-item>
      </gl-dropdown>

      <gl-dropdown style="width: 200px;">
        <gl-dropdown-item v-for="key in mappingKeys">{{key}}</gl-dropdown-item>
      </gl-dropdown>
    </div>

  </div>

</template>

<style scoped lang="scss">
  .mapping {
    display: flex;
    flex-direction: column;
  }
</style>
