import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { IssuableType } from '~/issue_show/constants';
import { parseBoolean } from '~/lib/utils/common_utils';
import { store } from '~/notes/stores';
import { apolloProvider } from '~/sidebar/graphql';
import * as CEMountSidebar from '~/sidebar/mount_sidebar';
import CveIdRequest from './components/cve_id_request/cve_id_request_sidebar.vue';
import IterationSidebarDropdownWidget from './components/iteration_sidebar_dropdown_widget.vue';
import SidebarDropdownWidget from './components/sidebar_dropdown_widget.vue';
import SidebarStatus from './components/status/sidebar_status.vue';
import SidebarWeight from './components/weight/sidebar_weight.vue';
import { IssuableAttributeType } from './constants';

Vue.use(VueApollo);

const mountWeightComponent = () => {
  const el = document.querySelector('.js-sidebar-weight-entry-point');

  if (!el) return false;

  return new Vue({
    el,
    components: {
      SidebarWeight,
    },
    render: (createElement) => createElement('sidebar-weight'),
  });
};

const mountStatusComponent = () => {
  const el = document.querySelector('.js-sidebar-status-entry-point');

  if (!el) {
    return false;
  }

  const { iid, fullPath, issuableType, canEdit } = el.dataset;

  return new Vue({
    el,
    apolloProvider,
    store,
    components: {
      SidebarStatus,
    },
    render: (createElement) =>
      createElement('sidebar-status', {
        props: {
          issuableType,
          iid,
          fullPath,
          canUpdate: parseBoolean(canEdit),
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

function mountEpicsSelect() {
  const el = document.querySelector('#js-vue-sidebar-item-epics-select');

  if (!el) return false;

  const { groupPath, canEdit, projectPath, issueIid } = el.dataset;

  return new Vue({
    el,
    apolloProvider,
    components: {
      SidebarDropdownWidget,
    },
    provide: {
      canUpdate: parseBoolean(canEdit),
      isClassicSidebar: true,
    },
    render: (createElement) =>
      createElement('sidebar-dropdown-widget', {
        props: {
          attrWorkspacePath: groupPath,
          workspacePath: projectPath,
          iid: issueIid,
          issuableType: IssuableType.Issue,
          issuableAttribute: IssuableAttributeType.Epic,
        },
      }),
  });
}

function mountIterationSelect() {
  const el = document.querySelector('.js-iteration-select');

  if (!el) {
    return false;
  }

  const { groupPath, canEdit, projectPath, issueIid } = el.dataset;

  const IterationDropdown = gon.features.iterationCadences
    ? IterationSidebarDropdownWidget
    : SidebarDropdownWidget;

  return new Vue({
    el,
    apolloProvider,
    provide: {
      canUpdate: parseBoolean(canEdit),
      isClassicSidebar: true,
    },
    render: (createElement) =>
      createElement(IterationDropdown, {
        props: {
          attrWorkspacePath: groupPath,
          workspacePath: projectPath,
          iid: issueIid,
          issuableType: IssuableType.Issue,
          issuableAttribute: IssuableAttributeType.Iteration,
        },
      }),
  });
}

export default function mountSidebar(mediator) {
  CEMountSidebar.mountSidebar(mediator);
  mountWeightComponent();
  mountStatusComponent(mediator);
  mountEpicsSelect();
  mountIterationSelect();

  if (gon.features.cveIdRequestButton) {
    mountCveIdRequestComponent();
  }
}
