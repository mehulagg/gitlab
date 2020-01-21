/* eslint-disable no-new */

import ActionCable from 'actioncable';
import MilestoneSelect from './milestone_select';
import LabelsSelect from './labels_select';
import IssuableContext from './issuable_context';
import Sidebar from './right_sidebar';

import DueDateSelectors from './due_date_select';

import createDefaultClient from '~/lib/graphql';
import issueSidebarSubscription from '~/issuable_sidebar/queries/issueSidebar.subscription.graphql';

export default () => {
  const sidebarOptions = JSON.parse(document.querySelector('.js-sidebar-options').innerHTML);

  new MilestoneSelect({
    full_path: sidebarOptions.fullPath,
  });
  new LabelsSelect();
  new IssuableContext(sidebarOptions.currentUser);
  new DueDateSelectors();
  Sidebar.initialize();

  if (sidebarOptions.type === 'issue') {
    const cable = ActionCable.createConsumer();

    cable.subscriptions.create(
      {
        channel: 'IssuesChannel',
        id: sidebarOptions.id,
      },
      {
        received(data) {
          console.log(data);
        },
      },
    );
  }
};
