import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { IssuableType } from '~/issue_show/constants';
import { parseBoolean } from '~/lib/utils/common_utils';
import { store } from '~/notes/stores';
import { apolloProvider } from '~/sidebar/graphql';
import * as CEMountSidebar from '~/sidebar/mount_sidebar';
import CveIdRequest from './components/cve_id_request/cve_id_request_sidebar.vue';
import SidebarItemEpicsSelect from './components/sidebar_item_epics_select.vue';
import SidebarIterationWidget from './components/sidebar_iteration_widget.vue';
import SidebarStatus from './components/status/sidebar_status.vue';
import SidebarWeight from './components/weight/sidebar_weight.vue';
import SidebarStore from './stores/sidebar_store';

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

function mountCveIdRequestComponent() {
  const el = document.getElementById('js-sidebar-cve-id-request-entry-point');

  if (!el) {
    return false;
  }

  const { iid, fullPath } = CEMountSidebar.getSidebarOptions();

  return new Vue({
    store,
    el,
    provide: {
      iid: String(iid),
      fullPath,
    },
    render: (createElement) => createElement(CveIdRequest),
  });
}

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

  const { groupPath, canEdit, projectPath, issueIid } = el.dataset;

  return new Vue({
    el,
    apolloProvider,
    components: {
      SidebarIterationWidget,
    },
    provide: {
      canUpdate: parseBoolean(canEdit),
      isClassicSidebar: true,
    },
    render: (createElement) =>
      createElement('sidebar-iteration-widget', {
        props: {
          iterationsWorkspacePath: groupPath,
          workspacePath: projectPath,
          iid: issueIid,
          issuableType: IssuableType.Issue,
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

  if (gon.features.cveIdRequestButton) {
    mountCveIdRequestComponent();
  }
}
