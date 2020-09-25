<script>
import { mapState, mapActions, mapGetters, mapMutations } from 'vuex';
import { GlDropdown, GlSearchBoxByType, GlDropdownItem, GlDropdownDivider } from '@gitlab/ui';
import { BDropdownForm } from 'bootstrap-vue';
import { ISSUABLE } from '~/boards/constants';
import AssigneeAvatarLink from '~/sidebar/components/assignees/assignee_avatar_link.vue';

export default {
  components: {
    BDropdownForm,
    GlDropdown,
    GlSearchBoxByType,
    GlDropdownItem,
    GlDropdownDivider,
    AssigneeAvatarLink,
  },
  data() {
    return {
      list: [], // figure out
      selected: [], // on mount make sure the right ones are there.
    };
  },
  computed: {
    ...mapGetters(['getActiveIssue']),
  },
  methods: {
    ...mapActions(['getAssignees']),
    updateAssignees(id) {
      console.log(id);
      // should prob emit event
      // trigger only on offclick
      // this.setAssignees();
      this.list = this.list.concat([]);
    },
  },
  mounted() {
    console.log('mounted'); // keep so we know when this is loaded, can we local cache this?
    this.getAssignees(`gid://gitlab/Issue/${this.getActiveIssue.iid}`).then(({ data }) => {
      this.list = data.issue.participants.edges.map(node => {
        console.log(node);
        return node.node;
      });
    });
  },
};
</script>

<template>
  <gl-dropdown class="show w-100" text="Assignees" header-text="Assign to">
    <b-dropdown-form class="w-100">
      <gl-search-box-by-type />
      <!-- If this is a button we have global handler issue -->
      <gl-dropdown-item class="mt-2" :is-checked="getActiveIssue.assignees.length === 0"
        ><li>Unassigned</li></gl-dropdown-item
      >
      <gl-dropdown-divider />
      <!-- Slot for list of items. -->

      <gl-dropdown-item @click="() => updateAssignees(x.id)" v-for="x in list">
        <assignee-avatar-link @click="() => updateAssignees(x.id)" :user="x" rootPath="''">
          <template #default="{ user }">
            <!-- Abstract this out its being used in a few places -->
            <span class="d-flex gl-flex-direction-column gl-overflow-hidden">
              <strong class="dropdown-menu-user-full-name">
                {{ user.name }}
              </strong>
              <span class="dropdown-menu-user-username">@{{ user.username }}</span>
            </span>
          </template>
        </assignee-avatar-link>
      </gl-dropdown-item>
    </b-dropdown-form>
  </gl-dropdown>
</template>
