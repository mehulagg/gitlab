export const initTopNav = async () => {
  const el = document.getElementById('js-top-nav');

  if (!el) {
    return;
  }

  const { mountTopNav } = await import(/* webpackChunkName: 'top_nav' */ './mount_top_nav');

  mountTopNav(el);
};
