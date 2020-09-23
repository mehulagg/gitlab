import $ from 'jquery';
import trackShowInviteMemberLink from 'ee/projects/track_invite_members';
import { mockTracking, unmockTracking } from 'helpers/tracking_helper';

describe('Track user dropdown open', () => {
  let trackingSpy;
  let selector;

  beforeEach(() => {
    setFixtures(`
      <div class="js-sidebar-assignee-dropdown">
      </div>`);

    selector = $('.js-sidebar-assignee-dropdown');
    trackingSpy = mockTracking('_category_', selector.element, jest.spyOn);
    document.body.dataset.page = 'some:page';

    trackShowInviteMemberLink(selector);
  });

  afterEach(() => {
    unmockTracking();
  });

  it('sends a tracking event when the dropdown is opened and contains Invite Members link', () => {
    selector.trigger('shown.bs.dropdown');

    expect(trackingSpy).toHaveBeenCalledWith(undefined, 'show_invite_members', {
      label: 'edit_assignee',
    });
  });
});
