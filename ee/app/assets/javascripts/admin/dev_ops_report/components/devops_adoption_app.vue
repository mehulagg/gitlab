<script>
import DevopsAdoptionEmptyState from './devops_adoption_empty_state.vue';
import DevopsAdoptionSegmentModal from './devops_adoption_segment_modal.vue';

export default {
  name: 'DevopsAdoptionApp',
  components: {
    DevopsAdoptionEmptyState,
    DevopsAdoptionSegmentModal,
  },
};
</script>
<template>
  <div>
    <devops-adoption-empty-state />
    <devops-adoption-segment-modal />
  </div>
</template>
