<script>
import { GlLink, GlSprintf } from '@gitlab/ui';
import SeverityBadge from 'ee/vue_shared/security_reports/components/severity_badge.vue';
import CodeBlock from '~/vue_shared/components/code_block.vue';
import { __ } from '~/locale';
import DetailItem from './detail_item.vue';

export default {
  name: 'VulnerabilityDetails',
  components: { CodeBlock, GlLink, SeverityBadge, DetailItem, GlSprintf },
  props: {
    vulnerability: {
      type: Object,
      required: true,
    },
  },
  computed: {
    location() {
      return this.vulnerability.location || {};
    },
    stacktraceSnippet() {
      return this.vulnerability.stacktrace_snippet || '';
    },
    scanner() {
      return this.vulnerability.scanner || {};
    },
    fileText() {
      return (this.location.file || '') + (this.lineNumber ? `:${this.lineNumber}` : '');
    },
    fileUrl() {
      return (this.location.blob_path || '') + (this.lineNumber ? `#L${this.lineNumber}` : '');
    },
    lineNumber() {
      const { start_line: start, end_line: end } = this.location;
      return end > start ? `${start}-${end}` : start;
    },
    scannerUrl() {
      return this.scanner.url || '';
    },
    scannerDetails() {
      if (this.scannerUrl) {
        return {
          component: 'GlLink',
          properties: {
            href: this.scannerUrl,
            target: '_blank',
          },
        };
      }

      return {
        component: 'span',
        properties: {},
      };
    },
    requestData() {
      if (!this.vulnerability.request) {
        return [];
      }

      const { method, url, headers = [] } = this.vulnerability.request;

      return [
        {
          label: __('%{labelStart}Method:%{labelEnd} %{method}'),
          content: method,
        },
        {
          label: __('%{labelStart}URL:%{labelEnd} %{url}'),
          content: url,
        },
        {
          label: __('%{labelStart}Headers:%{labelEnd} %{headers}'),
          content: this.getHeadersAsCodeBlockLines(headers),
          isCode: true,
        },
      ].filter(x => x.content);
    },
    responseData() {
      if (!this.vulnerability.response) {
        return [];
      }

      const {
        status_code: statusCode,
        reason_phrase: reasonPhrase,
        headers = [],
      } = this.vulnerability.response;

      return [
        {
          label: __('%{labelStart}Status:%{labelEnd} %{status}'),
          content: statusCode && reasonPhrase ? `${statusCode} ${reasonPhrase}` : '',
        },
        {
          label: __('%{labelStart}Headers:%{labelEnd} %{headers}'),
          content: this.getHeadersAsCodeBlockLines(headers),
          isCode: true,
        },
      ].filter(x => x.content);
    },
    shouldShowLocation() {
      return (
        this.location.crash_address ||
        this.location.crash_type ||
        this.location.stacktrace_snippet ||
        this.location.file ||
        this.location.image ||
        this.location.operating_system
      );
    },
  },
  methods: {
    getHeadersAsCodeBlockLines(headers) {
      return Array.isArray(headers)
        ? headers.map(({ name, value }) => `${name}: ${value}`).join('\n')
        : '';
    },
  },
};
</script>

<template>
  <div class="md" data-qa-selector="vulnerability_details">
    <h1
      class="mt-3 mb-2 border-bottom-0"
      data-testid="title"
      data-qa-selector="vulnerability_title"
    >
      {{ vulnerability.title }}
    </h1>
    <h3 class="mt-0">{{ __('Description') }}</h3>
    <p data-testid="description" data-qa-selector="vulnerability_description">
      {{ vulnerability.description }}
    </p>

    <ul>
      <detail-item :sprintf-message="__('%{labelStart}Severity:%{labelEnd} %{severity}')">
        <severity-badge :severity="vulnerability.severity" class="gl-display-inline ml-1" />
      </detail-item>
      <detail-item :sprintf-message="__('%{labelStart}Scan Type:%{labelEnd} %{reportType}')"
        >{{ vulnerability.report_type }}
      </detail-item>
      <detail-item
        v-if="scanner.name"
        :sprintf-message="__('%{labelStart}Scanner:%{labelEnd} %{scanner}')"
      >
        <component
          :is="scannerDetails.component"
          v-bind="scannerDetails.properties"
          data-testid="scannerSafeLink"
        >
          <gl-sprintf
            v-if="scanner.version"
            :message="s__('Vulnerability|%{scannerName} (version %{scannerVersion})')"
          >
            <template #scannerName>{{ scanner.name }}</template>
            <template #scannerVersion>{{ scanner.version }}</template>
          </gl-sprintf>
          <template v-else>{{ scanner.name }}</template>
        </component>
      </detail-item>
      <detail-item
        v-if="location.class"
        :sprintf-message="__('%{labelStart}Class:%{labelEnd} %{class}')"
        >{{ location.class }}
      </detail-item>
      <detail-item
        v-if="location.method"
        :sprintf-message="__('%{labelStart}Method:%{labelEnd} %{method}')"
      >
        <code>{{ location.method }}</code>
      </detail-item>
      <detail-item
        v-if="vulnerability.evidence"
        :sprintf-message="__('%{labelStart}Evidence:%{labelEnd} %{evidence}')"
        >{{ vulnerability.evidence }}
      </detail-item>
    </ul>

    <template v-if="shouldShowLocation">
      <h3>{{ __('Location') }}</h3>
      <ul>
        <detail-item
          v-if="location.image"
          :sprintf-message="__('%{labelStart}Image:%{labelEnd} %{image}')"
          >{{ location.image }}
        </detail-item>
        <detail-item
          v-if="location.operating_system"
          :sprintf-message="__('%{labelStart}Namespace:%{labelEnd} %{namespace}')"
          >{{ location.operating_system }}
        </detail-item>
        <detail-item
          v-if="location.file"
          :sprintf-message="__('%{labelStart}File:%{labelEnd} %{file}')"
        >
          <gl-link :href="fileUrl" target="_blank">{{ fileText }}</gl-link>
        </detail-item>
        <detail-item
          v-if="location.crash_address"
          :sprintf-message="__('%{labelStart}Crash Address:%{labelEnd} %{crash_address}')"
          >{{ location.crash_address }}
        </detail-item>
        <detail-item
          v-if="location.stacktrace_snippet"
          :sprintf-message="__('%{labelStart}Crash State:%{labelEnd} %{stacktrace_snippet}')"
        >
          <code-block :code="location.stacktrace_snippet" max-height="225px" />
        </detail-item>
      </ul>
    </template>

    <template v-if="vulnerability.links && vulnerability.links.length">
      <h3>{{ __('Links') }}</h3>
      <ul>
        <li
          v-for="(link, index) in vulnerability.links"
          :key="`${index}:${link.url}`"
          class="gl-ml-0! gl-list-style-position-inside"
        >
          <gl-link
            :href="link.url"
            data-testid="link"
            target="_blank"
            :aria-label="__('Third Party Advisory Link')"
            :title="link.url"
          >
            {{ link.url }}
          </gl-link>
        </li>
      </ul>
    </template>

    <template v-if="vulnerability.identifiers && vulnerability.identifiers.length">
      <h3>{{ __('Identifiers') }}</h3>
      <ul>
        <li
          v-for="(identifier, index) in vulnerability.identifiers"
          :key="`${index}:${identifier.url}`"
          class="gl-ml-0! gl-list-style-position-inside"
        >
          <gl-link :href="identifier.url" data-testid="identifier" target="_blank">
            {{ identifier.name }}
          </gl-link>
        </li>
      </ul>
    </template>

    <section v-if="requestData.length" data-testid="request">
      <h3>{{ s__('Vulnerability|Request') }}</h3>
      <ul>
        <detail-item
          v-for="({ label, isCode, content }, index) in requestData"
          :key="`${index}:${label}`"
          :sprintf-message="label"
        >
          <code-block v-if="isCode" class="mt-1" :code="content" max-height="225px" />
          <template v-else>
            {{ content }}
          </template>
        </detail-item>
      </ul>
    </section>

    <section v-if="responseData.length" data-testid="response">
      <h3>{{ s__('Vulnerability|Response') }}</h3>
      <ul>
        <detail-item
          v-for="({ label, isCode, content }, index) in responseData"
          :key="`${index}:${label}`"
          :sprintf-message="label"
        >
          <code-block v-if="isCode" class="mt-1" :code="content" max-height="225px" />
          <template v-else>
            {{ content }}
          </template>
        </detail-item>
      </ul>
    </section>
  </div>
</template>
