<script>
import { GlTabs, GlTab, GlBadge } from '@gitlab/ui';
import { isUndefined } from 'lodash';
import { mapState } from 'vuex';
import { urlParamsToObject } from '~/lib/utils/common_utils';
import { __ } from '~/locale';
import { MEMBER_TYPES } from '../constants';
import MembersApp from './app.vue';

export default {
  name: 'MemberTabs',
  MEMBER_TYPES,
  components: { MembersApp, GlTabs, GlTab, GlBadge },
  inject: ['canManageMembers'],
  data() {
    return {
      selectedTabIndex: 0,
    };
  },
  computed: {
    ...mapState({
      userCount(state) {
        return state[MEMBER_TYPES.user].pagination.totalItems;
      },
      groupCount(state) {
        return state[MEMBER_TYPES.group].pagination.totalItems;
      },
      inviteCount(state) {
        return state[MEMBER_TYPES.invite].pagination.totalItems;
      },
      accessRequestCount(state) {
        return state[MEMBER_TYPES.accessRequest].pagination.totalItems;
      },
    }),
    tabs() {
      return [
        {
          namespace: MEMBER_TYPES.user,
          count: this.userCount,
          title: __('Members'),
        },
        {
          namespace: MEMBER_TYPES.group,
          count: this.groupCount,
          title: __('Groups'),
        },
        {
          namespace: MEMBER_TYPES.invite,
          count: this.inviteCount,
          title: __('Invites'),
        },
        {
          namespace: MEMBER_TYPES.accessRequest,
          count: this.accessRequestCount,
          title: __('Access requests'),
        },
      ];
    },
    showGroupsTab() {
      return this.groupCount > 0;
    },
    showInvitesTab() {
      return this.canManageMembers && this.inviteCount > 0;
    },
    showAccessRequestsTab() {
      return this.canManageMembers && this.accessRequestCount > 0;
    },
  },
  mounted() {
    const urlParams = urlParamsToObject(window.location.search);
    const tabParams = this.tabs.reduce((accumulator, { namespace }, index) => {
      const state = this.$store.state[namespace];
      return {
        ...accumulator,
        ...(state?.pagination?.paramName && { [state.pagination.paramName]: index }),
        ...(state?.filteredSearchBar?.searchParam && {
          [state.filteredSearchBar.searchParam]: index,
        }),
      };
    }, {});

    for (let index = 0; index < Object.keys(urlParams).length; index += 1) {
      const urlParam = Object.keys(urlParams)[index];

      if (!isUndefined(tabParams[urlParam])) {
        this.selectedTabIndex = tabParams[urlParam];

        break;
      }
    }
  },
};
</script>

<template>
  <gl-tabs v-model="selectedTabIndex">
    <gl-tab v-for="tab in tabs" :key="tab.namespace">
      <template slot="title">
        <span>{{ tab.title }}</span>
        <gl-badge size="sm" class="gl-tab-counter-badge">{{ tab.count }}</gl-badge>
      </template>
      <members-app :namespace="tab.namespace" />
    </gl-tab>
  </gl-tabs>
</template>
