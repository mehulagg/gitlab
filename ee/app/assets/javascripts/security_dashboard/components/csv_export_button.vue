<script>
import { GlPopover, GlIcon, GlLink, GlButton, GlTooltipDirective } from '@gitlab/ui';
import { __, s__ } from '~/locale';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { formatDate } from '~/lib/utils/datetime_utility';
import pollUntilComplete from '~/lib/utils/poll_until_complete';
import download from '~/lib/utils/downloader';

export const STORAGE_KEY = 'vulnerability_csv_export_popover_dismissed';

export default {
  components: {
    GlIcon,
    GlButton,
    GlPopover,
    GlLink,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    vulnerabilitiesExportEndpoint: {
      type: String,
      required: true,
    },
  },
  data: () => ({
    isPreparingCsvExport: false,
    showPopover: localStorage.getItem(STORAGE_KEY) !== 'true',
  }),
  computed: {
    buttonProps() {
      const { isPreparingCsvExport } = this;
      return {
        title: __('Export as CSV'),
        loading: isPreparingCsvExport,
        ...(!isPreparingCsvExport ? { icon: 'export' } : {}),
      };
    },
  },
  methods: {
    closePopover() {
      this.showPopover = false;

      try {
        localStorage.setItem(STORAGE_KEY, 'true');
      } catch (e) {
        // Ignore the error - this is just a safety measure.
      }
    },
    initiateCsvExport() {
      this.isPreparingCsvExport = true;
      this.closePopover();

      axios
        .post(this.vulnerabilitiesExportEndpoint)
        .then(({ data }) => pollUntilComplete(data._links.self))
        .then(({ data }) => {
          if (data.status !== 'finished') {
            throw new Error();
          }
          download({
            fileName: `csv-export-${formatDate(new Date(), 'isoDateTime')}.csv`,
            url: data._links.download,
          });
        })
        .catch(() => {
          createFlash(s__('SecurityReports|There was an error while generating the report.'));
        })
        .finally(() => {
          this.isPreparingCsvExport = false;
        });
    },
  },
};
</script>
<template>
  <gl-button
    ref="csvExportButton"
    v-gl-tooltip.hover
    class="gl-align-self-center"
    v-bind="buttonProps"
    @click="initiateCsvExport"
  >
    {{ __('Export') }}
    <gl-popover
      ref="popover"
      :target="() => $refs.csvExportButton.$el"
      :show="showPopover"
      placement="left"
      triggers="manual"
    >
      <p class="gl-font-base">
        {{ __('You can now export your security dashboard to a CSV report.') }}
      </p>
      <gl-link
        ref="popoverExternalLink"
        target="_blank"
        href="https://gitlab.com/gitlab-org/gitlab/issues/197111"
        class="d-flex align-items-center mb-3"
      >
        {{ __('More information and share feedback') }}
        <gl-icon name="external-link" :size="12" class="ml-1" />
      </gl-link>
      <gl-button ref="popoverButton" class="w-100" @click="closePopover">
        {{ __('Got it!') }}
      </gl-button>
    </gl-popover>
  </gl-button>
</template>
