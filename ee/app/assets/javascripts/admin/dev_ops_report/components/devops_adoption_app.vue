<script>
import DevopsAdoptionEmptyState from './devops_adoption_empty_state.vue';
import DevopsAdoptionTable from './devops_adoption_table.vue';

export default {
  name: 'DevopsAdoptionApp',
  components: {
    DevopsAdoptionEmptyState,
    DevopsAdoptionTable,
  },
  data() {
    return {
      tableData: [
        {
          hello: 'world',
        },
      ],
    };
  },
};
</script>
<template>
  <devops-adoption-empty-state v-if="!tableData.length" />
  <devops-adoption-table v-else />
</template>
