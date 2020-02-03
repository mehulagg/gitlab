<script>
import Store from '~/sidebar/stores/sidebar_store';

export default {
  data() {
    return {
      store: new Store(),
    };
  },
};
</script>

<template>
  <div>
    <div v-if="store.assignees.length === 0">
      <input
        type="hidden"
        :value="null"
        name="issue[assignee_ids][]"
      />
    </div>
    <div v-else v-for="a in store.assignees" :key="a.id">
      <input
        type="hidden"
        :data-id="a.id"
        :value="a.id"
        name="issue[assignee_ids][]"
        :data-avatar-url="a.avatar_url"
        :data-name="a.name"
        :data-username="a.username"
      />
    </div>
  </div>
</template>
