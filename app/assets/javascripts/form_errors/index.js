const init = async () => {
  const els = document.querySelectorAll('.js-form-errors-explanation');

  if (els.length) {
    const { default: mount } = await import(/* webpackChunkName: 'form_errors' */ './mount');
    els.forEach(el => mount({ el }));
  }
}

export default init;
