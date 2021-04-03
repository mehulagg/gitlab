<script>
import {
  GlAvatarLabeled,
  GlAvatarLink,
  GlBadge,
  GlDropdown,
  GlDropdownItem,
  GlModalDirective,
  GlPagination,
  GlSearchBoxByType,
  GlTable,
  GlTooltipDirective,
} from '@gitlab/ui';
import { parseInt, debounce } from 'lodash';
import { mapActions, mapState, mapGetters } from 'vuex';
import {
  FIELDS,
  AVATAR_SIZE,
  SEARCH_DEBOUNCE_MS,
  REMOVE_BILLABLE_MEMBER_MODAL_ID,
} from 'ee/billings/seat_usage/constants';
import { s__ } from '~/locale';
import RemoveBillableMemberModal from './remove_billable_member_modal.vue';

export default {
  directives: {
    GlModal: GlModalDirective,
    GlTooltip: GlTooltipDirective,
  },
  components: {
    GlAvatarLabeled,
    GlAvatarLink,
    GlBadge,
    GlDropdown,
    GlDropdownItem,
    GlPagination,
    GlSearchBoxByType,
    GlTable,
    RemoveBillableMemberModal,
  },
  data() {
    return {
      searchQuery: '',
    };
  },
  computed: {
    ...mapState([
      'isLoading',
      'page',
      'perPage',
      'total',
      'namespaceName',
      'namespaceId',
      'billableMemberToRemove',
    ]),
    ...mapGetters(['tableItems']),
    currentPage: {
      get() {
        return parseInt(this.page, 10);
      },
      set(val) {
        this.fetchBillableMembersList({ page: val, search: this.searchQuery });
      },
    },
    perPageFormatted() {
      return parseInt(this.perPage, 10);
    },
    totalFormatted() {
      return parseInt(this.total, 10);
    },
    emptyText() {
      if (this.searchQuery?.length < 3) {
        return s__('Billing|Enter at least three characters to search.');
      }
      return s__('Billing|No users to display.');
    },
  },
  watch: {
    searchQuery() {
      this.executeQuery();
    },
  },
  created() {
    // This method is defined here instead of in `methods`
    // because we need to access the .cancel() method
    // lodash attaches to the function, which is
    // made inaccessible by Vue. More info:
    // https://stackoverflow.com/a/52988020/1063392
    this.debouncedSearch = debounce(function search() {
      this.fetchBillableMembersList({ search: this.searchQuery });
    }, SEARCH_DEBOUNCE_MS);

    this.fetchBillableMembersList();
  },
  methods: {
    ...mapActions([
      'fetchBillableMembersList',
      'resetBillableMembers',
      'setBillableMemberToRemove',
    ]),
    onSearchEnter() {
      this.debouncedSearch.cancel();
      this.executeQuery();
    },
    executeQuery() {
      const queryLength = this.searchQuery?.length;
      const MIN_SEARCH_LENGTH = 3;

      if (queryLength === 0 || queryLength >= MIN_SEARCH_LENGTH) {
        this.debouncedSearch();
      } else if (queryLength < MIN_SEARCH_LENGTH) {
        this.resetBillableMembers();
      }
    },
  },
  i18n: {
    emailNotVisibleTooltipText: s__(
      'Billing|An email address is only visible for users with public emails.',
    ),
  },
  avatarSize: AVATAR_SIZE,
  fields: FIELDS,
  removeBillableMemberModalId: REMOVE_BILLABLE_MEMBER_MODAL_ID,
};
</script>

<template>
  <section>
    <div
      class="gl-bg-gray-10 gl-p-6 gl-md-display-flex gl-justify-content-space-between gl-align-items-center"
    >
      <div data-testid="heading-info">
        <h4
          data-testid="heading-info-text"
          class="gl-font-base gl-display-inline-block gl-font-weight-normal"
        >
          {{ s__('Billing|Users occupying seats in') }}
          <span class="gl-font-weight-bold">{{ namespaceName }} {{ s__('Billing|Group') }}</span>
        </h4>
        <gl-badge>{{ total }}</gl-badge>
      </div>

      <gl-search-box-by-type
        v-model.trim="searchQuery"
        :placeholder="s__('Billing|Type to search')"
        @keydown.enter.prevent="onSearchEnter"
      />
    </div>

    <gl-table
      class="seats-table"
      :items="tableItems"
      :fields="$options.fields"
      :busy="isLoading"
      :show-empty="true"
      data-testid="table"
      :empty-text="emptyText"
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
            :title="$options.i18n.emailNotVisibleTooltipText"
            class="gl-font-style-italic"
          >
            {{ s__('Billing|Private') }}
          </span>
        </div>
      </template>

      <template #cell(lastActivityTime)="data">
        <span>
          {{ data.item.user.last_activity_on ? data.item.user.last_activity_on : __('Never') }}
        </span>
      </template>

      <template #cell(actions)="data">
        <gl-dropdown icon="ellipsis_h" right data-testid="user-actions">
          <gl-dropdown-item
            v-gl-modal="$options.removeBillableMemberModalId"
            @click="setBillableMemberToRemove(data.item.user)"
          >
            {{ __('Remove user') }}
          </gl-dropdown-item>
        </gl-dropdown>
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

    <remove-billable-member-modal
      v-if="billableMemberToRemove"
      :modal-id="$options.removeBillableMemberModalId"
    />
  </section>
</template>
