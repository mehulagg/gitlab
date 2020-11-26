<script>
import SidebarContext from '../sidebar_context';

import EpicHeader from './epic_header.vue';
import EpicBody from './epic_body.vue';

export default {
  components: {
    EpicHeader,
    EpicBody,
  },
  mounted() {
    this.sidebarContext = new SidebarContext();
  },
};
</script>

<template>
  <div class="epic-page-container">
    <epic-header />
    <epic-body />
  </div>
</template>
