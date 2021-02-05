<script>
import { GlModal, GlIcon, GlSprintf, GlTruncate, GlLink } from '@gitlab/ui';
import { n__, __ } from '~/locale';

export default {
  components: { GlModal, GlIcon, GlSprintf, GlTruncate, GlLink },
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
      text: __('Done'),
      attributes: { variant: 'default' },
    },
  },
  computed: {
    title() {
      return n__('%d Scanned URL', '%d Scanned URLs', this.scannedResourcesCount);
    },
    limitedScannedUrls() {
      // show only 15 scanned urls
      return this.scannedUrls.slice(0, 15);
    },
  },
};
</script>
<template>
  <gl-modal :title="title" title-tag="h5" v-bind="$options.modal">
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
            __(
              'To view all %{scannedResourcesCount} scanned URLs, %{linkStart}please download the CSV file%{linkEnd}',
            )
          "
        >
          <template #link="{ content }">
            <gl-link download :href="downloadLink" data-testid="download-link">
              {{ content }}
            </gl-link>
          </template>
          <template #scannedResourcesCount>
            {{ scannedResourcesCount }}
          </template>
        </gl-sprintf>
      </b>
    </div>
  </gl-modal>
</template>
