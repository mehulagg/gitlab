import { getSidebarOptions } from '~/sidebar/mount_sidebar';
import Mediator from './sidebar_mediator';
import mountSidebar from './mount_sidebar';
import mountTest from '~/sidebar/components/assignees/mount_user_select_hidden_input';

export default () => {
  const mediator = new Mediator(getSidebarOptions());
  mediator.fetch();

  // i dont like needing this in 2 places ee/ce
  mountTest();
  mountSidebar(mediator);
};
