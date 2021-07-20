<script>
import { GlLink, GlTooltipDirective, GlIcon, GlLoadingIcon } from '@gitlab/ui';
import {
  severityGroupTypes,
  severityLevels,
  severityLevelsTranslations,
  SEVERITY_LEVELS_ORDERED_BY_SEVERITY,
  SEVERITY_GROUPS,
} from 'ee/security_dashboard/store/modules/vulnerable_projects/constants';
import { Accordion, AccordionItem } from 'ee/vue_shared/components/accordion';

export default {
  css: {
    severityGroups: {
      [severityGroupTypes.F]: 'gl-text-red-900',
      [severityGroupTypes.D]: 'gl-text-red-700',
      [severityGroupTypes.C]: 'gl-text-orange-600',
      [severityGroupTypes.B]: 'gl-text-orange-400',
      [severityGroupTypes.A]: 'gl-text-green-500',
    },
    severityLevels: {
      [severityLevels.CRITICAL]: 'gl-text-red-900',
      [severityLevels.HIGH]: 'gl-text-red-700',
      [severityLevels.UNKNOWN]: 'gl-text-gray-300',
      [severityLevels.MEDIUM]: 'gl-text-orange-600',
      [severityLevels.LOW]: 'gl-text-orange-500',
      [severityLevels.NONE]: 'gl-text-green-500',
    },
  },
  accordionItemsContentMaxHeight: '445px',
  components: { Accordion, AccordionItem, GlLink, GlIcon, GlLoadingIcon },
  directives: {
    'gl-tooltip': GlTooltipDirective,
  },
  inject: ['groupFullPath'],
  props: {
    helpPagePath: {
      type: String,
      required: false,
      default: '',
    },
    query: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      vulnerabilityGrades: {},
      errorLoadingVulnerabilitiesGrades: false,
    };
  },
  apollo: {
    vulnerabilityGrades: {
      query() {
        return this.query;
      },
      variables() {
        return {
          fullPath: this.groupFullPath,
        };
      },
      update(results) {
        return this.processRawData(results);
      },
      error() {
        this.errorLoadingVulnerabilitiesGrades = true;
      },
    },
  },
  computed: {
    isLoadingGrades() {
      return this.$apollo.queries.vulnerabilityGrades.loading;
    },
    severityGroups() {
      return SEVERITY_GROUPS.map((group) => ({
        ...group,
        projects: this.findProjectsForGroup(group),
      }));
    },
  },
  methods: {
    findProjectsForGroup(group) {
      if (!this.vulnerabilityGrades[group.type]) {
        return [];
      }

      return this.vulnerabilityGrades[group.type].map((project) => ({
        ...project,
        mostSevereVulnerability: this.findMostSevereVulnerabilityForGroup(project, group),
      }));
    },
    findMostSevereVulnerabilityForGroup(project, group) {
      const mostSevereVulnerability = {};

      SEVERITY_LEVELS_ORDERED_BY_SEVERITY.some((level) => {
        if (!group.severityLevels.includes(level)) {
          return false;
        }

        const hasVulnerabilityForThisLevel = project.vulnerabilitySeveritiesCount?.[level] > 0;

        if (hasVulnerabilityForThisLevel) {
          mostSevereVulnerability.level = level;
          mostSevereVulnerability.count = project.vulnerabilitySeveritiesCount[level];
        }

        return hasVulnerabilityForThisLevel;
      });

      return mostSevereVulnerability;
    },
    processRawData(results) {
      const { vulnerabilityGrades } = this.groupFullPath
        ? results.group
        : results.instanceSecurityDashboard;

      return vulnerabilityGrades.reduce((acc, v) => {
        acc[v.grade] = v.projects.nodes;
        return acc;
      }, {});
    },
    shouldAccordionItemBeDisabled({ projects }) {
      return projects?.length < 1;
    },
    cssForSeverityGroup({ type }) {
      return this.$options.css.severityGroups[type];
    },
    cssForMostSevereVulnerability({ level }) {
      return this.$options.css.severityLevels[level] || [];
    },
    severityText(severityLevel) {
      return severityLevelsTranslations[severityLevel];
    },
  },
};
</script>

<template>
  <section
    class="gl-border-solid gl-border-1 gl-border-gray-100 gl-rounded-base gl-display-flex gl-flex-direction-column"
  >
    <header class="gl-p-5">
      <h4 class="gl-my-0">
        {{ __('Project security status') }}
        <gl-link
          v-if="helpPagePath"
          :href="helpPagePath"
          :aria-label="__('Project security status help page')"
          target="_blank"
          ><gl-icon name="question"
        /></gl-link>
      </h4>
      <p v-if="!isLoadingGrades" class="gl-text-gray-500 gl-m-0">
        {{ __('Projects are graded based on the highest severity vulnerability present') }}
      </p>
    </header>

    <gl-loading-icon v-if="isLoadingGrades" size="lg" class="gl-my-12" />
    <accordion
      v-else
      class="security-dashboard-accordion gl-px-5 gl-display-flex gl-flex-grow-1 gl-border-t-1 gl-border-t-solid gl-border-t-gray-100"
    >
      <template #default="{ accordionId }">
        <accordion-item
          v-for="severityGroup in severityGroups"
          :ref="`accordionItem${severityGroup.type}`"
          :key="severityGroup.type"
          :data-qa-selector="`severity_accordion_item_${severityGroup.type}`"
          :accordion-id="accordionId"
          :disabled="shouldAccordionItemBeDisabled(severityGroup)"
          :max-height="$options.accordionItemsContentMaxHeight"
          class="gl-display-flex gl-flex-grow-1 gl-flex-direction-column gl-justify-content-center"
        >
          <template #title="{ isExpanded, isDisabled }">
            <h5
              class="gl-display-flex gl-align-items-center gl-font-weight-normal gl-p-0 gl-m-0"
              data-testid="vulnerability-severity-groups"
            >
              <span
                v-gl-tooltip
                :title="severityGroup.description"
                class="gl-font-weight-bold gl-mr-5 gl-font-lg"
                :class="cssForSeverityGroup(severityGroup)"
              >
                {{ severityGroup.type }}
              </span>
              <span :class="{ 'gl-font-weight-bold': isExpanded, 'gl-text-gray-500': isDisabled }">
                {{ n__('%d project', '%d projects', severityGroup.projects.length) }}
              </span>
            </h5>
          </template>
          <template #sub-title>
            <p class="gl-m-0 gl-ml-7 gl-pb-2 gl-text-gray-500">{{ severityGroup.warning }}</p>
          </template>
          <div class="gl-ml-7 gl-pb-3">
            <ul class="list-unstyled gl-py-2">
              <li v-for="project in severityGroup.projects" :key="project.id" class="gl-py-3">
                <gl-link
                  target="_blank"
                  :href="project.securityDashboardPath"
                  data-qa-selector="project_name_text"
                  >{{ project.nameWithNamespace }}</gl-link
                >
                <span
                  v-if="project.mostSevereVulnerability"
                  ref="mostSevereCount"
                  class="gl-display-block text-lowercase"
                  :class="cssForMostSevereVulnerability(project.mostSevereVulnerability)"
                  >{{ project.mostSevereVulnerability.count }}
                  {{ severityText(project.mostSevereVulnerability.level) }}
                </span>
              </li>
            </ul>
          </div>
        </accordion-item>
      </template>
    </accordion>
  </section>
</template>
