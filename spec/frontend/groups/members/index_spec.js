import { createWrapper } from '@vue/test-utils';
import {
  initGroupMembersApp,
  memberRequestFormatter,
  groupLinkRequestFormatter,
} from '~/groups/members';
import GroupMembersApp from '~/groups/members/components/app.vue';
import { membersJsonString, membersParsed } from './mock_data';

describe('initGroupMembersApp', () => {
  let el;
  let vm;
  let wrapper;

  const setup = () => {
    vm = initGroupMembersApp(el, ['account'], () => 'foo bar');
    wrapper = createWrapper(vm);
  };

  beforeEach(() => {
    el = document.createElement('div');
    el.setAttribute('data-members', membersJsonString);
    el.setAttribute('data-group-id', '234');
    el.setAttribute('data-member-path', '/groups/foo-bar/-/group_members/:id');

    window.gon = { current_user_id: 123 };

    document.body.appendChild(el);
  });

  afterEach(() => {
    document.body.innerHTML = '';
    el = null;

    wrapper.destroy();
    wrapper = null;
  });

  it('renders `GroupMembersApp`', () => {
    setup();

    expect(wrapper.find(GroupMembersApp).exists()).toBe(true);
  });

  it('sets `currentUserId` in Vuex store', () => {
    setup();

    expect(vm.$store.state.currentUserId).toBe(123);
  });

  describe('when `gon.current_user_id` is not set (user is not logged in)', () => {
    it('sets `currentUserId` as `null` in Vuex store', () => {
      window.gon = {};
      setup();

      expect(vm.$store.state.currentUserId).toBeNull();
    });
  });

  it('parses and sets `data-group-id` as `sourceId` in Vuex store', () => {
    setup();

    expect(vm.$store.state.sourceId).toBe(234);
  });

  it('parses and sets `members` in Vuex store', () => {
    setup();

    expect(vm.$store.state.members).toEqual(membersParsed);
  });

  it('sets `tableFields` in Vuex store', () => {
    setup();

    expect(vm.$store.state.tableFields).toEqual(['account']);
  });

  it('sets `requestFormatter` in Vuex store', () => {
    setup();

    expect(vm.$store.state.requestFormatter()).toBe('foo bar');
  });

  it('sets `memberPath` in Vuex store', () => {
    setup();

    expect(vm.$store.state.memberPath).toBe('/groups/foo-bar/-/group_members/:id');
  });
});

describe('memberRequestFormatter', () => {
  it('returns expected format', () => {
    expect(
      memberRequestFormatter({
        accessLevel: 50,
        expires_at: '2020-10-16',
      }),
    ).toEqual({ group_member: { access_level: 50, expires_at: '2020-10-16' } });
  });
});

describe('groupLinkRequestFormatter', () => {
  it('returns expected format', () => {
    expect(
      groupLinkRequestFormatter({
        accessLevel: 50,
        expires_at: '2020-10-16',
      }),
    ).toEqual({ group_link: { group_access: 50, expires_at: '2020-10-16' } });
  });
});
