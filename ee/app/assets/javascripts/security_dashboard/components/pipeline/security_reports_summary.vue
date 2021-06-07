<script>
import {
  GlButton,
  GlCard,
  GlCollapse,
  GlCollapseToggleDirective,
  GlSprintf,
  GlModalDirective,
  GlLink,
} from '@gitlab/ui';
import { COLLAPSE_SECURITY_REPORTS_SUMMARY_LOCAL_STORAGE_KEY as LOCAL_STORAGE_KEY } from 'ee/security_dashboard/constants';
import { getFormattedSummary } from 'ee/security_dashboard/helpers';
import Modal from 'ee/vue_shared/security_reports/components/dast_modal.vue';
import AccessorUtilities from '~/lib/utils/accessor';
import { __ } from '~/locale';

export default {
  name: 'SecurityReportsSummary',
  components: {
    GlButton,
    GlCard,
    GlCollapse,
    GlSprintf,
    Modal,
    GlLink,
  },
  directives: {
    collapseToggle: GlCollapseToggleDirective,
    GlModal: GlModalDirective,
  },
  props: {
    summary: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      isVisible: true,
    };
  },
  computed: {
    collapseButtonLabel() {
      return this.isVisible ? __('Hide details') : __('Show details');
    },
    formattedSummary() {
      return getFormattedSummary(this.summary);
    },
  },
  watch: {
    isVisible(isVisible) {
      if (!this.localStorageUsable) {
        return;
      }
      if (isVisible) {
        localStorage.removeItem(LOCAL_STORAGE_KEY);
      } else {
        localStorage.setItem(LOCAL_STORAGE_KEY, '1');
      }
    },
  },
  created() {
    this.localStorageUsable = AccessorUtilities.isLocalStorageAccessSafe();
    if (this.localStorageUsable) {
      const shouldHideSummaryDetails = Boolean(localStorage.getItem(LOCAL_STORAGE_KEY));
      this.isVisible = !shouldHideSummaryDetails;
    }
  },
  methods: {
    hasScannedResources(scanSummary) {
      return scanSummary.scannedResources?.nodes?.length > 0;
    },
    downloadLink(scanSummary) {
      return scanSummary.scannedResourcesCsvPath || '';
    },
  },
};
</script>

<template>
  <gl-card body-class="gl-py-0" header-class="gl-border-b-0">
    <template #header>
      <div class="row">
        <div class="col-7">
          <strong>{{ s__('SecurityReports|Scan details') }}</strong>
        </div>
        <div v-if="localStorageUsable" class="col-5 gl-text-right">
          <gl-button
            v-collapse-toggle.security-reports-summary-details
            data-testid="collapse-button"
          >
            {{ collapseButtonLabel }}
          </gl-button>
        </div>
      </div>
    </template>
    <gl-collapse id="security-reports-summary-details" v-model="isVisible" class="gl-pb-3">
      <div v-for="[scanType, scanSummary] in formattedSummary" :key="scanType" class="row gl-my-3">
        <div class="col-6 col-md-4 col-lg-2">
          {{ scanType }}
        </div>
        <div class="col-6 col-md-8 col-lg-10">
          <gl-sprintf
            :message="
              n__('%d vulnerability', '%d vulnerabilities', scanSummary.vulnerabilitiesCount)
            "
          />
          <template v-if="scanSummary.scannedResourcesCount !== undefined">
            <gl-button
              v-if="hasScannedResources(scanSummary)"
              v-gl-modal.dastUrl
              variant="link"
              data-testid="modal-button"
            >
              (<gl-sprintf
                :message="
                  n__('%d URL scanned', '%d URLs scanned', scanSummary.scannedResourcesCount)
                "
              />)
            </gl-button>

            <template v-else>
              (<gl-sprintf
                :message="
                  n__('%d URL scanned', '%d URLs scanned', scanSummary.scannedResourcesCount)
                "
              />)
            </template>

            <modal
              v-if="hasScannedResources(scanSummary)"
              :scanned-urls="scanSummary.scannedResources.nodes"
              :scanned-resources-count="scanSummary.scannedResourcesCount"
              :download-link="downloadLink(scanSummary)"
            />
          </template>
          <template v-else-if="scanSummary.scannedResourcesCsvPath">
            <gl-link
              download
              :href="downloadLink(scanSummary)"
              class="gl-ml-1"
              data-testid="download-link"
            >
              ({{ s__('SecurityReports|Download scanned resources') }})
            </gl-link>
          </template>
        </div>
      </div>
    </gl-collapse>
  </gl-card>
</template>
