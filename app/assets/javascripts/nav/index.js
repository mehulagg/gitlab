import { mountTopNav, mountTopNavResponsive } from './mount';

const tryMountTopNav = async () => {
  const el = document.getElementById('js-top-nav');

  if (!el) {
    return;
  }

  mountTopNav(el);
};

const tryMountTopNavResponsive = async () => {
  const el = document.getElementById('js-top-nav-responsive');

  if (!el) {
    return;
  }

  mountTopNavResponsive(el);
};

export const initTopNav = async () => Promise.all([tryMountTopNav(), tryMountTopNavResponsive()]);
