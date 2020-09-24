<script>
import Api from '~/api';
import AuditFilterToken from './shared/audit_filter_token.vue';

export default {
  components: {
    AuditFilterToken,
  },
  inheritAttrs: false,
  tokenMethods: {
    fetchItem(id) {
      return Api.user(id).then(res => res.data);
    },
    fetchSuggestions(term) {
      return Api.users(term).then(res => res.data);
    },
    getItemName({ name }) {
      return name;
    },
  },
};
</script>

<template>
  <audit-filter-token v-bind="{ ...this.$attrs, ...this.$options.tokenMethods }" v-on="$listeners">
    <template #suggestion="{item: user}">
      <p class="m-0">{{ user.name }}</p>
      <p class="m-0">@{{ user.username }}</p>
    </template>
  </audit-filter-token>
</template>
