<script>
import { camelCase } from 'lodash';
import { mapState, mapActions } from 'vuex';
import { GlDeprecatedSkeletonLoading as GlSkeletonLoading } from '@gitlab/ui';
import { LICENSE_CHECK_NAME, VULNERABILITY_CHECK_NAME, JOB_TYPES } from 'ee/approvals/constants';
import { s__ } from '~/locale';
import UnconfiguredSecurityRule from './unconfigured_security_rule.vue';

export default {
  components: {
    UnconfiguredSecurityRule,
    GlSkeletonLoading,
  },
  inject: {
    vulnerabilityCheckHelpPagePath: {
      from: 'vulnerabilityCheckHelpPagePath',
      default: '',
    },
    licenseCheckHelpPagePath: {
      from: 'licenseCheckHelpPagePath',
      default: '',
    },
  },
  featureTypes: {
    vulnerabilityCheck: [
      JOB_TYPES.SAST,
      JOB_TYPES.DAST,
      JOB_TYPES.DEPENDENCY_SCANNING,
      JOB_TYPES.SECRET_DETECTION,
      JOB_TYPES.COVERAGE_FUZZING,
    ],
    licenseCheck: [JOB_TYPES.LICENSE_SCANNING],
  },
  computed: {
    ...mapState('securityConfiguration', ['configuration']),
    ...mapState({
      rules: state => state.approvals.rules,
      isApprovalsLoading: state => state.approvals.isLoading,
      isSecurityConfigurationLoading: state => state.securityConfiguration.isLoading,
    }),
    isRulesLoading() {
      return this.isApprovalsLoading || this.isSecurityConfigurationLoading;
    },
    securityRules() {
      return [
        {
          name: VULNERABILITY_CHECK_NAME,
          description: s__(
            'SecurityApprovals|One or more of the security scanners must be enabled. %{linkStart}More information%{linkEnd}',
          ),
          enableDescription: s__(
            'SecurityApprovals|Requires approval for vulnerabilities of Critical, High, or Unknown severity. %{linkStart}More information%{linkEnd}',
          ),
          docsPath: this.vulnerabilityCheckHelpPagePath,
        },
        {
          name: LICENSE_CHECK_NAME,
          description: s__(
            'SecurityApprovals|License Scanning must be enabled. %{linkStart}More information%{linkEnd}',
          ),
          enableDescription: s__(
            'SecurityApprovals|Requires license policy rules for licenses of Allowed, or Denied. %{linkStart}More information%{linkEnd}',
          ),
          docsPath: this.licenseCheckHelpPagePath,
        },
      ];
    },
    unconfiguredRules() {
      return this.securityRules.reduce((filtered, securityRule) => {
        const hasApprovalRuleDefined = this.hasApprovalRuleDefined(securityRule);
        const hasConfiguredJob = this.hasConfiguredJob(securityRule);

        if (!hasApprovalRuleDefined || !hasConfiguredJob) {
          filtered.push({ ...securityRule, hasConfiguredJob });
        }
        return filtered;
      }, []);
    },
  },
  created() {
    this.fetchSecurityConfiguration();
  },
  methods: {
    ...mapActions('securityConfiguration', ['fetchSecurityConfiguration']),
    ...mapActions({ openCreateModal: 'createModal/open' }),
    hasApprovalRuleDefined(matchRule) {
      return this.rules.some(rule => {
        return matchRule.name === rule.name;
      });
    },
    hasConfiguredJob(matchRule) {
      const { features = [] } = this.configuration;
      return this.$options.featureTypes[camelCase(matchRule.name)].some(featureType => {
        return features.some(feature => {
          return feature.type === featureType && feature.configured;
        });
      });
    },
  },
};
</script>

<template>
  <table class="table m-0">
    <tbody>
      <tr v-if="isRulesLoading">
        <td colspan="3">
          <gl-skeleton-loading :lines="3" />
        </td>
      </tr>

      <unconfigured-security-rule
        v-for="rule in unconfiguredRules"
        v-else
        :key="rule.name"
        :rule="rule"
        @enable="openCreateModal({ defaultRuleName: rule.name })"
      />
    </tbody>
  </table>
</template>
