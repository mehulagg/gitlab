<script>
import { mapActions, mapState, mapGetters } from 'vuex';
import {
  GlTable,
  GlAvatarLabeled,
  GlAvatarLink,
  GlPagination,
  GlLoadingIcon,
  GlTooltipDirective,
} from '@gitlab/ui';
import { parseInt } from 'lodash';
import { s__, sprintf } from '~/locale';

const AVATAR_SIZE = 32;

export default {
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    GlTable,
    GlAvatarLabeled,
    GlAvatarLink,
    GlPagination,
    GlLoadingIcon,
  },
  data() {
    return {
      fields: ['user', 'email'],
    };
  },
  computed: {
    ...mapState(['isLoading', 'page', 'perPage', 'total', 'namespaceId', 'namespaceName']),
    ...mapGetters(['tableItems']),
    headingText() {
      return sprintf(s__('Billing|Users occupying seats in %{namespaceName} Group (%{total})'), {
        total: this.total,
        namespaceName: this.namespaceName,
      });
    },
    subHeadingText() {
      return s__('Billing|Updated live');
    },
    currentPage: {
      get() {
        return parseInt(this.page, 10);
      },
      set(val) {
        this.fetchBillableMembersList(val);
      },
    },
    perPageFormatted() {
      return parseInt(this.perPage, 10);
    },
    totalFormatted() {
      return parseInt(this.total, 10);
    },
  },
  created() {
    this.fetchBillableMembersList(1);
  },
  methods: {
    ...mapActions(['fetchBillableMembersList']),
    inputHandler(val) {
      this.fetchBillableMembersList(val);
    },
  },
  avatarSize: AVATAR_SIZE,
  emailNotVisibleTooltipText: s__(
    'Billing|An email address is only visible for users managed through Group Managed Accounts.',
  ),
};
</script>

<template>
  <div class="gl-pt-4">
    <h4 data-testid="heading">{{ headingText }}</h4>
    <p>{{ subHeadingText }}</p>
    <gl-table
      class="seats-table"
      :items="tableItems"
      :fields="fields"
      :busy="isLoading"
      :show-empty="true"
      data-testid="table"
    >
      <template #cell(user)="data">
        <div class="gl-display-flex">
          <gl-avatar-link target="blank" :href="data.value.web_url" :alt="data.value.name">
            <gl-avatar-labeled
              :src="data.value.avatar_url"
              :size="$options.avatarSize"
              :label="data.value.name"
              :sub-label="data.value.username"
            />
          </gl-avatar-link>
        </div>
      </template>

      <template #cell(email)="data">
        <div data-testid="email">
          <span v-if="data.value" class="gl-text-gray-900">{{ data.value }}</span>
          <span
            v-else
            v-gl-tooltip
            :title="$options.emailNotVisibleTooltipText"
            class="gl-font-style-italic"
            >{{ s__('Billing|Private') }}</span
          >
        </div>
      </template>

      <template #empty>
        {{ s__('Billing|No users to display.') }}
      </template>

      <template #table-busy>
        <gl-loading-icon size="lg" color="dark" class="gl-mt-5" />
      </template>
    </gl-table>

    <gl-pagination
      v-if="currentPage"
      v-model="currentPage"
      :per-page="perPageFormatted"
      :total-items="totalFormatted"
      align="center"
      class="gl-mt-5"
    />
  </div>
</template>
