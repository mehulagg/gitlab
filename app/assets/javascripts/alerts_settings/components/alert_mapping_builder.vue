<script>
  import {s__, __} from '~/locale';
  import {
    GlIcon,
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
    i18n: {
      columns: {
        gitlabKeyTitle: s__('AlertMappingBuilder|GitLab alert key'),
        payloadKeyTitle: s__('AlertMappingBuilder|Payload alert key'),
        substituteKeyTitle: s__('AlertMappingBuilder|Define substitute'),
      },
      selectMapping: __('Select mapping'),
    },
    components: {
      GlIcon,
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
        testAlert: null,
        gitlabFields: [
          {
            key: 'title',
            title: __('Title'),
            type: 'String',
            mapping: null,
          },
          {
            key: 'title',
            title: __('Description'),
            type: 'String',
            mapping: null,
          },
          {
            key: 'startTime',
            title: __('Start time'),
            type: 'DateTime',
            mapping: null,
          },
          {
            key: 'service',
            title: __('Service'),
            type: 'String',
            mapping: null,
          },
          {
            key: 'monitoringTool',
            title: __('Monitoring tool'),
            type: 'String',
            mapping: null,
          },
          {
            key: 'hosts',
            title: __('Monitoring tool'),
            type: 'String or Array',
            mapping: null,
          },
          {
            key: 'severity',
            title: __('Severity'),
            type: 'String',
            mapping: null,
          },
          {
            key: 'fingerprint',
            title: __('Fingerprint'),
            type: 'String',
            mapping: null,
          },
          {
            key: 'environment',
            title: __('Environment'),
            type: 'String',
            mapping: null,
          },
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
  <div class="gl-display-flex gl-flex-direction-column">
    <div class="gl-display-inline-flex gl-justify-content-space-between">
      <h5>{{$options.i18n.columns.gitlabKeyTitle}}</h5>
      <h5>{{$options.i18n.columns.payloadKeyTitle}}</h5>
      <h5>{{$options.i18n.columns.substituteKeyTitle}}</h5>
    </div>
    <div v-for="gitlabField in gitlabFields"
         :key="gitlabField.key"
         class="gl-mb-5 gl-display-inline-flex">
      <gl-form-input disabled :value="`${gitlabField.title} (${gitlabField.type})`" class="gl-mr-2"/>

      <gl-icon name="arrow-right" />
      <gl-dropdown :text="gitlabField.mapping || $options.i18n.selectMappiing" class="gl-mr-5">
        <gl-dropdown-item v-for="mappingKey in mappingKeys"
                          :key="mappingKey"
                          @click="selectMapping(gitlabField.key, mappingKey)">
          {{mappingKey}}
        </gl-dropdown-item>
      </gl-dropdown>

      <gl-dropdown>
        <gl-dropdown-item v-for="key in mappingKeys" :key="key">{{key}}</gl-dropdown-item>
      </gl-dropdown>
    </div>
  </div>

</template>

<style scoped lang="scss">

</style>
