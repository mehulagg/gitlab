<script>
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import axios from '~/lib/utils/axios_utils';
import downloader from '~/lib/utils/downloader';

export default {
  components: {
    GlDropdown,
    GlDropdownItem,
  },
  props: {
    state: {
      required: true,
      type: Object,
    },
  },
  methods: {
    downloadVersion() {
      axios({
        url: this.state.latestVersion.downloadPath,
        type: 'GET',
        responseType: 'blob',
      })
        .then(response => {
          downloader({
            fileName: `${this.state.name}.json`,
            url: window.URL.createObjectURL(response.data),
          });
        })
        .catch(() => {});
    },
  },
};
</script>

<template>
  <div
    v-if="state.latestVersion"
    class="gl-display-flex gl-justify-content-end gl-flex-direction-column gl-align-items-flex-end gl-pl-3"
  >
    <gl-dropdown icon="ellipsis_v" right :data-testid="`terraform-state-actions-${state.name}`">
      <gl-dropdown-item data-testid="terraform-state-download" @click="downloadVersion">
        {{ s__('Terraform|Download latest (JSON)') }}
      </gl-dropdown-item>
    </gl-dropdown>
  </div>
</template>
