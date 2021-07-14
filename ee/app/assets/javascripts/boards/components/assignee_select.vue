<script>
import {
  GlDropdown,
  GlDropdownForm,
  GlDropdownDivider,
  GlDropdownItem,
  GlSearchBoxByType,
  GlLoadingIcon,
} from '@gitlab/ui';
import { isEmpty } from 'lodash';
import { mapGetters } from 'vuex';
import searchUsers from '~/graphql_shared/queries/users_search.query.graphql';
import { __ } from '~/locale';
import SidebarParticipant from '~/sidebar/components/assignees/sidebar_participant.vue';
import { ASSIGNEES_DEBOUNCE_DELAY } from '~/sidebar/constants';
import UserAvatarImage from '~/vue_shared/components/user_avatar/user_avatar_image.vue';

export default {
  components: {
    UserAvatarImage,
    GlDropdown,
    GlDropdownForm,
    GlDropdownDivider,
    GlDropdownItem,
    GlSearchBoxByType,
    GlLoadingIcon,
    SidebarParticipant,
  },
  inject: {
    fullPath: {
      default: '',
    },
  },
  props: {
    anyUserText: {
      type: String,
      required: false,
      default: __('Any user'),
    },
    board: {
      type: Object,
      required: true,
    },
    canEdit: {
      type: Boolean,
      required: false,
      default: false,
    },
    fieldName: {
      type: String,
      required: true,
    },
    groupId: {
      type: Number,
      required: false,
      default: 0,
    },
    label: {
      type: String,
      required: true,
    },
    placeholderText: {
      type: String,
      required: false,
      default: __('Select user'),
    },
    projectId: {
      type: Number,
      required: false,
      default: 0,
    },
    // selected: {
    //   type: Object,
    //   required: false,
    //   default: () => null,
    // },
    wrapperClass: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      search: '',
      users: [],
      isLoading: false,
      selected: this.board.assignee,
      isEditing: false,
    };
  },
  apollo: {
    users: {
      query: searchUsers,
      variables() {
        return {
          fullPath: this.fullPath,
          search: this.search,
          first: 20,
          isGroup: this.isGroupBoard,
          isProject: this.isProjectBoard,
        };
      },
      skip() {
        return !this.isEditing;
      },
      update(data) {
        return data.workspace?.users?.nodes.filter((x) => x?.user).map(({ user }) => user) || [];
      },
      debounce: ASSIGNEES_DEBOUNCE_DELAY,
      error() {
        this.$emit('error');
        this.isLoading = false;
      },
      result() {
        this.isLoading = false;
      },
    },
  },
  computed: {
    ...mapGetters(['isGroupBoard', 'isProjectBoard']),
    hasValue() {
      return this.selected && this.selected.id > 0;
    },
    selectedId() {
      return this.selected ? this.selected.id : null;
    },
    isSearchEmpty() {
      return this.search === '';
    },
    selectedIsEmpty() {
      return isEmpty(this.selected) || this.selected === null;
    },
    noUsersFound() {
      return !this.isSearchEmpty && this.users.length === 0;
    },
  },
  watch: {
    // We need to add this watcher to track the moment when user is alredy typing
    // but query is still not started due to debounce
    search(newVal) {
      if (newVal) {
        this.isSearching = true;
      }
    },
  },
  methods: {
    selectAssignee(user) {
      this.selected = user;
    },
    toggleEdit() {
      this.isEditing = !this.isEditing;
    },
  },
  i18n: {
    anyAssignee: __('Any assignee'),
    selectAssignee: __('Select assignee'),
  },
};
</script>

<template>
  <div :class="wrapperClass" class="block">
    <div class="title gl-mb-3">
      {{ label }}
      <button
        v-if="canEdit"
        type="button"
        class="edit-link btn btn-blank float-right"
        @click="toggleEdit"
      >
        {{ __('Edit') }}
      </button>
    </div>
    <div class="value">
      <div v-if="hasValue" class="media gl-display-flex gl-align-items-center">
        <div class="align-center">
          <user-avatar-image :img-src="selected.avatar_url" :size="32" />
        </div>
        <div class="media-body">
          <div class="bold author">{{ selected.name }}</div>
          <div class="username">@{{ selected.username }}</div>
        </div>
      </div>
      <div v-else class="text-secondary">{{ anyUserText }}</div>
    </div>

    <gl-dropdown
      v-if="isEditing"
      class="show"
      :text="$options.i18n.selectAssignee"
      @toggle="$emit('toggle')"
    >
      <template #header>
        <gl-search-box-by-type ref="search" v-model.trim="search" class="js-dropdown-input-field" />
      </template>
      <gl-dropdown-form class="gl-relative gl-min-h-7">
        <gl-loading-icon
          v-if="isLoading"
          data-testid="loading-users"
          size="md"
          class="gl-absolute gl-left-0 gl-top-0 gl-right-0"
        />
        <template v-else>
          <gl-dropdown-item
            v-if="isSearchEmpty"
            :is-checked="selectedIsEmpty"
            :is-check-centered="true"
            data-testid="unassign"
            @click="$emit('input', [])"
          >
            <span :class="selectedIsEmpty ? 'gl-pl-0' : 'gl-pl-6'" class="gl-font-weight-bold">
              {{ $options.i18n.anyAssignee }}
            </span>
          </gl-dropdown-item>
          <gl-dropdown-divider />
          <gl-dropdown-item
            v-for="user in users"
            :key="user.id"
            data-testid="unselected-user"
            @click="selectAssignee(user)"
          >
            <sidebar-participant :user="user" class="gl-pl-6!" />
          </gl-dropdown-item>
          <gl-dropdown-item v-if="noUsersFound" data-testid="empty-results" class="gl-pl-6!">
            {{ __('No matching results') }}
          </gl-dropdown-item>
        </template>
      </gl-dropdown-form>
      <template #footer>
        <slot name="footer"></slot>
      </template>
    </gl-dropdown>
  </div>
</template>
