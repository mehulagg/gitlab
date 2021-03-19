import $ from 'jquery';
import Tracking from '~/tracking';

export default function initTrackInviteMembers(assigneeDropdown) {
  const trackLabel = 'edit_assignee';
  const { trackEvent } = assigneeDropdown.querySelector('.js-invite-members-track').dataset;

  $(assigneeDropdown).on('shown.bs.dropdown', () => {
    Tracking.event(undefined, trackEvent, {
      label: trackLabel,
    });
  });
}
