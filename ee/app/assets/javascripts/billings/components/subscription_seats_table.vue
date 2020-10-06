<script>
import { GlTable, GlAvatarLabeled, GlAvatarLink, GlPagination } from '@gitlab/ui';

import Api from '~/api';
import { __, sprintf } from '~/locale';
// TODO - use the new one
import { deprecatedCreateFlash as createFlash } from '~/flash';

export default {
  components: {
    GlTable,
    GlAvatarLabeled,
    GlAvatarLink,
    GlPagination,
  },
  props: {
    namespaceId: {
      type: String,
      required: true,
      default: '',
    },
    namespaceName: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      memberList: [],
      fields: ['user'],
      page: 2,
    };
  },
  computed: {
    isMemberListShown() {
      return this.memberList.length;
    },
    items() {
      return this.memberList.map(({ name, username, avatar_url, web_url }) => {
        return { user: { name, username, avatar_url, web_url } };
      });
    },
    headingText() {
      return sprintf(__('Users occupying seats in %{namespaceName}'), {
        namespaceName: this.namespaceName,
      });
    },
  },
  mounted() {
    this.fetchMembers(this.namespaceId);
  },
  methods: {
    fetchMembers(groupId) {
      Api.fetchBillableGroupMembersList(groupId)
        .then(({ data }) => {
          this.memberList = data;
        })
        .catch(() => {
          createFlash(__('An error occurred while loading billable members list'));
        });
    },
  },
};
</script>

<template>
  <div v-if="isMemberListShown">
    <h4>{{ headingText }}</h4>

    <gl-table class="seats-table" :items="items" :fields="fields">
      <template #cell(user)="data">
        <gl-avatar-link target="blank" :href="data.value.web_url" :alt="data.value.name">
          <gl-avatar-labeled
            :src="data.value.avatar_url"
            :size="32"
            :label="data.value.name"
            :sub-label="data.value.username"
          />
        </gl-avatar-link>
      </template>
    </gl-table>

    <gl-pagination v-model="page" :per-page="10" :total-items="100" align="center" />
  </div>
</template>
