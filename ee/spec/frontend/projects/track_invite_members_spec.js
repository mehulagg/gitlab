import $ from 'jquery';
import trackShowInviteMemberLink from 'ee/projects/track_invite_members';
import { mockTracking, unmockTracking } from 'helpers/tracking_helper';

describe('Track user dropdown open', () => {
  let trackingSpy;
  let dropdownElement;

  beforeEach(() => {
    document.body.innerHTML = `
      <div id="dummy-wrapper-element">
        <div class="js-sidebar-assignee-dropdown">
          <div class="js-invite-members-track" data-track-event="_track_event_">
          </div>
        </div>
      </div>
    `;

    dropdownElement = document.querySelector('.js-sidebar-assignee-dropdown');
    trackingSpy = mockTracking('_category_', dropdownElement, jest.spyOn);
    document.body.dataset.page = 'some:page';

    trackShowInviteMemberLink(dropdownElement);
  });

  afterEach(() => {
    unmockTracking();
  });

  it('sends a tracking event when the dropdown is opened and contains Invite Members link', () => {
    $(dropdownElement).trigger('shown.bs.dropdown');

    expect(trackingSpy).toHaveBeenCalledWith(undefined, '_track_event_', {
      label: 'edit_assignee',
    });
  });
});
