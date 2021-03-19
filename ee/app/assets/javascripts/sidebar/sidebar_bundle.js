import { getSidebarOptions } from '~/sidebar/mount_sidebar';
import mountSidebar from './mount_sidebar';
import Mediator from './sidebar_mediator';

export default () => {
  const sidebarOptEl = document.querySelector('.js-sidebar-options');

  if (!sidebarOptEl) return;

  const mediator = new Mediator(getSidebarOptions(sidebarOptEl));
  mediator.fetch();

  mountSidebar(mediator);
};
