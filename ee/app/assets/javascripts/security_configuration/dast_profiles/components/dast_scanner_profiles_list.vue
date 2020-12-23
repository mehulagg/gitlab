<script>
import ProfilesList from './dast_profiles_list.vue';

export default {
  components: {
    ProfilesList,
  },
};
</script>
<template>
  <profiles-list v-bind="$attrs" v-on="$listeners">
    <template #cell(scanType)="{ value }">
      <b>{{ value }}</b>
    </template>
  </profiles-list>
</template>
