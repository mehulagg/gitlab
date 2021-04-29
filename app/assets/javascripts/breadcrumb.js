import $ from 'jquery';
import { hide } from '~/tooltips';

export const addTooltipToEl = (el) => {
  const textEl = el.querySelector('.js-breadcrumb-item-text');

  if (textEl && textEl.scrollWidth > textEl.offsetWidth) {
    el.setAttribute('title', el.textContent);
    el.setAttribute('data-container', 'body');
    el.classList.add('has-tooltip');
  }
};

export default () => {
  const breadcrumbs = document.querySelector('.js-breadcrumbs-list');

  if (breadcrumbs) {
    const topLevelLinks = [...breadcrumbs.children]
      .filter((el) => !el.classList.contains('dropdown'))
      .map((el) => el.querySelector('a'))
      .filter((el) => el);
    topLevelLinks.forEach((el) => addTooltipToEl(el));

    const $expander = $('.js-breadcrumbs-collapsed-expander');
    $expander.closest('.dropdown').on('show.bs.dropdown hide.bs.dropdown', (e) => {
      const $el = $('.js-breadcrumbs-collapsed-expander', e.currentTarget);

      hide($el);
    });
  }
};
