<script>
import { GlAlert, GlTabs, GlTab, GlSafeHtmlDirective } from '@gitlab/ui';
import { PARSING_ERROR_MESSAGE } from './constants';

export default {
  i18n: {
    PARSING_ERROR_MESSAGE,
  },
  components: {
    GlAlert,
    GlTabs,
    GlTab,
  },
  directives: {
    safeHtml: GlSafeHtmlDirective,
  },
  props: {
    policyYaml: {
      type: String,
      required: true,
    },
    policyDescription: {
      type: String,
      required: false,
      default: '',
    },
    initialTab: {
      type: Number,
      required: false,
      default: 0,
    },
  },
  data() {
    return { selectedTab: this.initialTab };
  },
  safeHtmlConfig: { ALLOWED_TAGS: ['strong', 'br'] },
};
</script>

<template>
  <gl-tabs v-model="selectedTab" content-class="gl-pt-0">
    <gl-tab :title="s__('NetworkPolicies|Rule')">
      <div
        v-if="policyDescription"
        v-safe-html:[$options.safeHtmlConfig]="policyDescription"
        class="gl-bg-white gl-rounded-top-left-none gl-rounded-top-right-none gl-rounded-bottom-left-base gl-rounded-bottom-right-base gl-py-3 gl-px-4 gl-border-1 gl-border-solid gl-border-gray-100 gl-border-t-none!"
      ></div>
      <div v-else>
        <gl-alert variant="info" :dismissible="false">
          {{ $options.i18n.PARSING_ERROR_MESSAGE }}
        </gl-alert>
      </div>
    </gl-tab>
    <gl-tab :title="s__('NetworkPolicies|.yaml')">
      <pre class="gl-bg-white gl-rounded-top-left-none gl-rounded-top-right-none gl-border-t-none"
        >{{ policyYaml }}
      </pre>
    </gl-tab>
  </gl-tabs>
</template>
