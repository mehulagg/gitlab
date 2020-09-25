import { toggleContainerClasses } from '~/lib/utils/dom_utils';
import initSidebarBundle from '~/sidebar/sidebar_bundle';
import initRelatedIssues from '~/related_issues';
import initShow from '../../issues/show';

document.addEventListener('DOMContentLoaded', () => {
  const containerEl = document.querySelector('.page-with-contextual-sidebar');
  const rightSidebarExpanded = document
    .querySelector('.js-issuable-sidebar')
    .classList.contains('right-sidebar-expanded');

  toggleContainerClasses(containerEl, {
    'right-sidebar-expanded': rightSidebarExpanded,
    'right-sidebar-collapsed': !rightSidebarExpanded,
  });

  initShow();
  if (gon.features && !gon.features.vueIssuableSidebar) {
    initSidebarBundle();
  }
  initRelatedIssues();
});
