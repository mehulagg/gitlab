<script>
import { GlAccordion, GlAccordionItem, GlAlert, GlButton, GlSprintf } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  components: {
    GlAccordion,
    GlAccordionItem,
    GlAlert,
    GlButton,
    GlSprintf,
  },
  inject: ['securityReportHelpPageLink'],
  props: {
    scans: {
      type: Array,
      required: true,
    },
  },
  computed: {
    scansWithTitles() {
      return this.scans.map((scan) => ({
        ...scan,
        title: `${scan.name} (${scan.errors.length})`,
      }));
    },
  },
  i18n: {
    title: s__('SecurityReports|Error parsing security reports'),
    description: s__(
      'SecurityReports|The security reports below contain one or more vulnerability findings that could not be parsed and were not recorded. Download the artifacts in the job output to investigate. Ensure any security report created conforms to the relevant %{helpPageLinkStart}JSON schema%{helpPageLinkEnd}.',
    ),
  },
};
</script>

<template>
  <gl-alert variant="danger" :dismissible="false">
    <strong role="heading">
      {{ $options.i18n.title }}
    </strong>
    <p class="gl-mt-3">
      <gl-sprintf :message="$options.i18n.description" data-testid="description">
        <template #helpPageLink="{ content }">
          <gl-button
            variant="link"
            icon="external-link"
            :href="securityReportHelpPageLink"
            target="_blank"
          >
            {{ content }}
          </gl-button>
        </template>
      </gl-sprintf>
    </p>
    <gl-accordion :header-level="3">
      <gl-accordion-item
        v-for="{ name, errors, title } in scansWithTitles"
        :key="name"
        :title="title"
      >
        <ul class="gl-pl-4">
          <li v-for="error in errors" :key="error">{{ error }}</li>
        </ul>
      </gl-accordion-item>
    </gl-accordion>
  </gl-alert>
</template>
