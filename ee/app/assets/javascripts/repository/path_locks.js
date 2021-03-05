import initConfirmModal from '~/confirm_modal';

export const initPathLocks = ({ selector }) => {
  const el = document.querySelector(selector);

  if (!el) {
    return null;
  }

  initConfirmModal({ selector });

  return el;
};
