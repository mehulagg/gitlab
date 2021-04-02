export const STORAGE_KEY = 'display-whats-new-notification';

export const getVersionDigest = (appEl) => appEl.getAttribute('data-version-digest');

export const setNotification = (appEl) => {
  const versionDigest = getVersionDigest(appEl);
  const notificationEl = document.querySelector('.header-help');
  let notificationCountEl = notificationEl.querySelector('.js-whats-new-notification-count');

  // FIXME - Prevent notification from firing on .com until next release.
  // can we do anything about self-manged?
  let notified = localStorage.getItem(STORAGE_KEY) === versionDigest;
  if(Date.parse(new Date()) < Date.parse('Apr 23, 2021')) {
    notified = JSON.parse(localStorage.getItem('display-whats-new-notification-13.10')) === false;
  }
  if (notified) {
    notificationEl.classList.remove('with-notifications');
    if (notificationCountEl) {
      notificationCountEl.parentElement.removeChild(notificationCountEl);
      notificationCountEl = null;
    }
  } else {
    notificationEl.classList.add('with-notifications');
  }
};
