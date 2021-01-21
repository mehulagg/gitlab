import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { parseBoolean } from '~/lib/utils/common_utils';
import * as CEMountSidebar from '~/sidebar/mount_sidebar';
import SidebarItemEpicsSelect from './components/sidebar_item_epics_select.vue';
import SidebarStatus from './components/status/sidebar_status.vue';
import SidebarWeight from './components/weight/sidebar_weight.vue';
import IterationSelect from './components/iteration_select.vue';
import SidebarStore from './stores/sidebar_store';
import createDefaultClient from '~/lib/graphql';
import { store } from '~/notes/stores';

Vue.use(VueApollo);

const mountWeightComponent = (mediator) => {
  const el = document.querySelector('.js-sidebar-weight-entry-point');

  if (!el) return false;

  return new Vue({
    el,
    components: {
      SidebarWeight,
    },
    render: (createElement) =>
      createElement('sidebar-weight', {
        props: {
          mediator,
        },
      }),
  });
};

const mountStatusComponent = (mediator) => {
  const el = document.querySelector('.js-sidebar-status-entry-point');

  if (!el) {
    return false;
  }

  return new Vue({
    el,
    store,
    components: {
      SidebarStatus,
    },
    render: (createElement) =>
      createElement('sidebar-status', {
        props: {
          mediator,
        },
      }),
  });
};

const mountEpicsSelect = () => {
  const el = document.querySelector('#js-vue-sidebar-item-epics-select');

  if (!el) return false;

  const { groupId, issueId, epicIssueId, canEdit } = el.dataset;
  const sidebarStore = new SidebarStore();

  return new Vue({
    el,
    components: {
      SidebarItemEpicsSelect,
    },
    render: (createElement) =>
      createElement('sidebar-item-epics-select', {
        props: {
          sidebarStore,
          groupId: Number(groupId),
          issueId: Number(issueId),
          epicIssueId: Number(epicIssueId),
          canEdit: parseBoolean(canEdit),
        },
      }),
  });
};

function mountIterationSelect() {
  const el = document.querySelector('.js-iteration-select');

  if (!el) {
    return false;
  }

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(),
  });
  const { groupPath, canEdit, projectPath, issueIid } = el.dataset;

  return new Vue({
    el,
    apolloProvider,
    components: {
      IterationSelect,
    },
    render: (createElement) =>
      createElement('iteration-select', {
        props: {
          groupPath,
          canEdit,
          projectPath,
          issueIid,
        },
      }),
  });
}

export default function mountSidebar(mediator) {
  CEMountSidebar.mountSidebar(mediator);
  mountWeightComponent(mediator);
  mountStatusComponent(mediator);
  mountEpicsSelect();
  mountIterationSelect();
}
