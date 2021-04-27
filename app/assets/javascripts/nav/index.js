const tryMountTopNav = async () => {
  const el = document.getElementById('js-top-nav');

  if (!el) {
    return;
  }

  // With combined_menu feature flag, there's a benefit to splitting up the import
  const { mountTopNav } = await import(/* webpackChunkName: 'top_nav' */ './mount');

  mountTopNav(el);
};

const tryMountTopNavResponsive = async () => {
  const el = document.getElementById('js-top-nav-responsive');

  if (!el) {
    return;
  }

  // With combined_menu feature flag, there's a benefit to splitting up the import
  const { mountTopNavResponsive } = await import(
    /* webpackChunkName: 'top_nav_responsive' */ './mount'
  );

  mountTopNavResponsive(el);
};

export const initTopNav = async () => Promise.all([tryMountTopNav(), tryMountTopNavResponsive()]);
