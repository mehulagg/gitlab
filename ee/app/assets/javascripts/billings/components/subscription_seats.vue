<script>
import { mapActions, mapState } from 'vuex';
import { GlTable, GlAvatarLabeled, GlAvatarLink, GlPagination, GlLoadingIcon } from '@gitlab/ui';
import { parseInt } from 'lodash';
import { s__, sprintf } from '~/locale';

const AVATAR_SIZE = 32;

export default {
  components: {
    GlTable,
    GlAvatarLabeled,
    GlAvatarLink,
    GlPagination,
    GlLoadingIcon,
  },
  props: {
    namespaceName: {
      type: String,
      required: true,
    },
    namespaceId: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      fields: ['user'],
    };
  },
  computed: {
    ...mapState('seats', ['members', 'isLoading', 'page', 'perPage', 'total']),
    items() {
      return this.members.map(({ name, username, avatar_url, web_url }) => {
        return { user: { name, username, avatar_url, web_url } };
      });
    },
    headingText() {
      return sprintf(
        s__('Billing|%{total} Users occupying seats in %{namespaceName} (Updated live)'),
        {
          total: this.total,
          namespaceName: this.namespaceName,
        },
      );
    },
    currentPage: {
      get() {
        return parseInt(this.page);
      },
      set(val) {
        this.fetchBillableMembersList(val);
      },
    },
  },
  created() {
    this.setNamespaceId(this.namespaceId);
    this.fetchBillableMembersList(1);
  },
  methods: {
    ...mapActions('seats', ['setNamespaceId', 'fetchBillableMembersList']),
    inputHandler(val) {
      this.fetchBillableMembersList(val);
    },
  },
  avatarSize: AVATAR_SIZE,
};
</script>

<template>
  <div>
    <h4 data-testid="heading">{{ headingText }}</h4>

    <gl-table
      data-testid="seats-table"
      class="seats-table"
      :items="items"
      :fields="fields"
      :busy="isLoading"
      :show-empty="true"
    >
      <template #cell(user)="data">
        <gl-avatar-link target="blank" :href="data.value.web_url" :alt="data.value.name">
          <gl-avatar-labeled
            :src="data.value.avatar_url"
            :size="$options.avatarSize"
            :label="data.value.name"
            :sub-label="data.value.username"
          />
        </gl-avatar-link>
      </template>

      <template #empty>
        {{ s__('Billing|No users to display.') }}
      </template>

      <template #table-busy>
        <gl-loading-icon size="lg" color="dark" class="mt-3" />
      </template>
    </gl-table>

    <gl-pagination
      v-if="currentPage"
      v-model="currentPage"
      :per-page="parseInt(perPage)"
      :total-items="parseInt(total)"
      align="center"
      class="gl-mt-5"
    />
  </div>
</template>
