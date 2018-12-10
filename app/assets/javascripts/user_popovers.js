import Vue from 'vue';

import UsersCache from './lib/utils/users_cache';
import UserPopover from './vue_shared/components/user_popover/user_popover.vue';

let renderedPopover;
let renderFn;

const handleUserPopoverMouseOut = event => {
  const { target } = event;
  target.removeEventListener('mouseleave', handleUserPopoverMouseOut);

  if (renderFn) {
    clearTimeout(renderFn);
  }
  if (renderedPopover) {
    renderedPopover.$destroy();
    renderedPopover = null;
  }
};

/**
 * Adds a UserPopover component to the body, hands over as much data as the target element has in data attributes.
 * loads based on data-user-id more data about a user from the API and sets it on the popover
 */
const handleUserPopoverMouseOver = event => {
  const { target } = event;
  // Add listener to actually remove it again
  target.addEventListener('mouseleave', handleUserPopoverMouseOut);

  renderFn = setTimeout(() => {
    // Helps us to use current markdown setup without maybe breaking or duplicating for now
    if (target.dataset.user) {
      target.dataset.userId = target.dataset.user;
      // Removing titles so its not showing tooltips also
      target.dataset.originalTitle = '';
      target.setAttribute('title', '');
    }

    const { userId, username, name, avatarUrl } = target.dataset;
    const user = {
      userId,
      username,
      name,
      avatarUrl,
      location: null,
      bio: null,
      organization: null,
      status: null,
    };
    if (userId || username) {
      const UserPopoverComponent = Vue.extend(UserPopover);
      renderedPopover = new UserPopoverComponent({
        propsData: {
          target,
          user,
        },
      });

      renderedPopover.$mount();

      UsersCache.retrieveById(userId)
        .then(userData => {
          if (!userData) {
            return;
          }

          Object.assign(user, {
            avatarUrl: userData.avatar_url,
            username: userData.username,
            name: userData.name,
            location: userData.location,
            bio: userData.bio,
            organization: userData.organization,
            loaded: true,
          });

          UsersCache.retrieveStatusById(userId)
            .then(status => {
              if (!status) {
                return;
              }

              Object.assign(user, {
                status,
              });
            })
            .catch(() => {
              throw new Error(`User status for "${userId}" could not be retrieved!`);
            });
        })
        .catch(() => {
          renderedPopover.$destroy();
          renderedPopover = null;
        });
    }
  }, 200);
};

export default elements => {
  let userLinks = elements;
  if (!elements) {
    userLinks = [...document.querySelectorAll('.js-user-link')];
  }

  userLinks.forEach(el => {
    el.addEventListener('mouseenter', handleUserPopoverMouseOver);
  });
};
