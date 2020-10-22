import $ from 'jquery';
import Tracking from '~/tracking';

export default function(assigneeDropdown) {
  const trackEvent = 'show_invite_members';
  const trackLabel = 'edit_assignee';

  $(assigneeDropdown).on('shown.bs.dropdown', () => {
    Tracking.event(undefined, trackEvent, {
      label: trackLabel,
    });
  });
}
