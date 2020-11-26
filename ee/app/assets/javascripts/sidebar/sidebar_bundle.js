import { getSidebarOptions } from '~/sidebar/mount_sidebar';
import Mediator from './sidebar_mediator';
import mountSidebar from './mount_sidebar';

export default () => {
  const sidebarOptEl = document.querySelector('.js-sidebar-options');

  if (!sidebarOptEl) return;

  const mediator = new Mediator(getSidebarOptions(sidebarOptEl));
  mediator.fetch();

  mountSidebar(mediator);
};
