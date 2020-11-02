<script>
import { GlModal, GlIcon, GlSprintf, GlTruncate } from '@gitlab/ui';
import { n__, __ } from '~/locale';
import axios from '~/lib/utils/axios_utils';
import download from '~/lib/utils/downloader';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';

export default {
  components: { GlModal, GlIcon, GlSprintf, GlTruncate },
  mixins: [glFeatureFlagsMixin()],
  data() {
    return {
      downloadPending: false
    }
  },
  props: {
    scannedUrls: {
      required: true,
      type: Array,
    },
    scannedResourcesCount: {
      required: true,
      type: Number,
    },
    downloadLink: {
      required: true,
      type: String,
    },
  },
  modal: {
    modalId: 'dastUrl',
    actionPrimary: {
      text: __('Close'),
      attributes: { variant: 'success' },
    },
  },
  methods: {
    async downloadReport() {
      const METHOD = 'GET';
      const RESPONSETYPE = 'blob';
      const URL = this.downloadLink;
      const FILENAME = 'scanned_resources';

      this.downloadPending = true;
      try {
        const CSVREPORT = await axios.request({url: URL, method: METHOD, responseType: RESPONSETYPE});
        download({ fileName: FILENAME, fileData: btoa(CSVREPORT), fileType: 'text/csv'});
        this.downloadPending = false;
      } catch(e) {
        this.downloadPending = false;
      }
    }
  },
  computed: {
    title() {
      return n__('%d Scanned URL', '%d Scanned URLs', this.scannedResourcesCount);
    },
    limitedScannedUrls() {
      // show only 15 scanned urls
      return this.scannedUrls.slice(0, 15);
    },
    downloadButton() {
      const buttonAttrs = {
        text: __('Download as CSV'),
        attributes: {
          variant: 'success',
          loading: this.glFeatures.dastModalLoadingIndicator ? this.downloadPending : false,
          href: this.glFeatures.dastModalLoadingIndicator ? undefined : this.downloadLink,
          class: 'gl-button btn-success-secondary',
          download: '',
          'data-testid': 'download-button',
        },
      };
      return this.downloadLink ? buttonAttrs : null;
    },
  }
};
</script>
<template>
  <span>
  <gl-modal
    data-testid="dastModal"
    :title="title"
    title-tag="h5"
    v-bind="$options.modal"
    v-if="this.glFeatures.dastModalLoadingIndicator"
    @secondary.prevent="downloadReport"
    :action-secondary="downloadButton"
  >
    <!-- heading -->
    <div class="row gl-text-gray-400">
      <div class="col-1">{{ __('Method') }}</div>
      <div class="col-11">{{ __('URL') }}</div>
    </div>
    <hr class="gl-my-3" />

    <!-- rows -->
    <div v-for="(url, index) in limitedScannedUrls" :key="index" class="row gl-my-2">
      <div class="col-1">{{ url.requestMethod.toUpperCase() }}</div>
      <div class="col-11" data-testid="dast-scanned-url">
        <gl-truncate :text="url.url" position="middle" />
      </div>
    </div>

    <!-- banner -->
    <div
      v-if="downloadLink"
      class="gl-display-inline-block gl-bg-gray-50 gl-my-3 gl-pl-3 gl-pr-7 gl-py-5"
    >
      <gl-icon name="bulb" class="gl-vertical-align-middle gl-mr-5" />
      <b class="gl-vertical-align-middle">
        <gl-sprintf
          :message="
            __('To view all %{scannedResourcesCount} scanned URLs, please download the CSV file')
          "
        >
          <template #scannedResourcesCount>
            {{ scannedResourcesCount }}
          </template>
        </gl-sprintf>
      </b>
    </div>
  </gl-modal>
    <gl-modal
    :title="title"
    title-tag="h5"
    v-bind="$options.modal"
    v-else
    :action-secondary="downloadButton"
  >
    <!-- heading -->
    <div class="row gl-text-gray-400">
      <div class="col-1">{{ __('Method') }}</div>
      <div class="col-11">{{ __('URL') }}</div>
    </div>
    <hr class="gl-my-3" />

    <!-- rows -->
    <div v-for="(url, index) in limitedScannedUrls" :key="index" class="row gl-my-2">
      <div class="col-1">{{ url.requestMethod.toUpperCase() }}</div>
      <div class="col-11" data-testid="dast-scanned-url">
        <gl-truncate :text="url.url" position="middle" />
      </div>
    </div>

    <!-- banner -->
    <div
      v-if="downloadLink"
      class="gl-display-inline-block gl-bg-gray-50 gl-my-3 gl-pl-3 gl-pr-7 gl-py-5"
    >
      <gl-icon name="bulb" class="gl-vertical-align-middle gl-mr-5" />
      <b class="gl-vertical-align-middle">
        <gl-sprintf
          :message="
            __('To view all %{scannedResourcesCount} scanned URLs, please download the CSV file')
          "
        >
          <template #scannedResourcesCount>
            {{ scannedResourcesCount }}
          </template>
        </gl-sprintf>
      </b>
    </div>
  </gl-modal>
  </span>
</template>
