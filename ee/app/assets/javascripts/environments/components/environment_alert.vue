<script>
import { GlLink, GlSprintf, GlTooltipDirective as GlTooltip } from '@gitlab/ui';
import SeverityBadge from 'ee/vue_shared/security_reports/components/severity_badge.vue';
import { s__ } from '~/locale';
import TimeagoMixin from '~/vue_shared/mixins/timeago';
import alertQuery from '../graphql/queries/environment.query.graphql';

export default {
  components: {
    GlLink,
    GlSprintf,
    SeverityBadge,
  },
  directives: {
    GlTooltip,
  },
  mixins: [TimeagoMixin],
  inject: {
    projectPath: {
      default: '',
    },
  },
  props: {
    environment: {
      required: true,
      type: Object,
    },
  },
  data() {
    return { alert: null };
  },
  apollo: {
    alert: {
      query: alertQuery,
      variables() {
        return {
          fullPath: this.projectPath,
          environmentName: this.environment.name,
        };
      },
      update(data) {
        return data?.project?.environment?.latestOpenedMostSevereAlert;
      },
    },
  },
  translations: {
    alertText: s__(
      'EnvironmentsAlert|%{severity} • %{title} %{text}. %{linkStart}View Details%{linkEnd} · %{startedAt} ',
    ),
  },
  computed: {
    humanizedText() {
      return this.alert?.prometheusAlert?.humanizedText;
    },
    severity() {
      return this.alert?.severity;
    },
  },
  classes: [
    'gl-py-2',
    'gl-pl-3',
    'gl-text-gray-900',
    'gl-bg-gray-10',
    'gl-border-t-solid',
    'gl-border-gray-100',
    'gl-border-1',
  ],
};
</script>
<template>
  <div v-if="alert" :class="$options.classes" data-testid="alert">
    <gl-sprintf :message="$options.translations.alertText">
      <template #severity>
        <severity-badge v-if="severity" :severity="severity" class="gl-display-inline" />
      </template>
      <template #startedAt>
        <span v-gl-tooltip :title="tooltipTitle(alert.startedAt)">
          {{ timeFormatted(alert.startedAt) }}
        </span>
      </template>
      <template #title>
        <span>{{ alert.title }}</span>
      </template>
      <template #text>
        <span>{{ humanizedText }}</span>
      </template>
      <template #link="{ content }">
        <gl-link :href="alert.detailsUrl" data-testid="alert-link">{{ content }}</gl-link>
      </template>
    </gl-sprintf>
  </div>
</template>
