import Mediator from './sidebar_mediator';
import mountTest from '~/sidebar/components/assignees/mount_user_select_hidden_input';
import { mountSidebar, getSidebarOptions } from './mount_sidebar';

export default () => {
  const mediator = new Mediator(getSidebarOptions());
  mediator.fetch();
  console.log('here')
  // need to figure out the can_merge situation, dont think i need to bc just doing issue
  mountTest();
  mountSidebar(mediator);
};
