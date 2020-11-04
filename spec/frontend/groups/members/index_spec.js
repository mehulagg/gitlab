import { createWrapper } from '@vue/test-utils';
import { initGroupMembersApp } from '~/groups/members';
import GroupMembersApp from '~/groups/members/components/app.vue';
import { membersJsonString, membersParsed } from './mock_data';

describe('initGroupMembersApp', () => {
  let el;
  let loadingEl;
  let vm;
  let wrapper;

  const setup = () => {
    vm = initGroupMembersApp(el, loadingEl, ['account'], () => ({}));
    wrapper = createWrapper(vm);
  };

  const findGroupMembersApp = () => wrapper.find(GroupMembersApp);

  beforeEach(() => {
    el = document.createElement('div');
    el.setAttribute('data-members', membersJsonString);
    el.setAttribute('data-group-id', '234');
    el.setAttribute('data-member-path', '/groups/foo-bar/-/group_members/:id');

    loadingEl = document.createElement('div');
    document.body.appendChild(loadingEl);

    window.gon = { current_user_id: 123 };
  });

  afterEach(() => {
    el = null;
    loadingEl = null;

    wrapper.destroy();
    wrapper = null;
  });

  it('renders `GroupMembersApp`', () => {
    setup();

    expect(findGroupMembersApp().exists()).toBe(true);
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

    expect(vm.$store.state.requestFormatter()).toEqual({});
  });

  it('sets `memberPath` in Vuex store', () => {
    setup();

    expect(vm.$store.state.memberPath).toBe('/groups/foo-bar/-/group_members/:id');
  });

  it('passes `loadingEl` as prop', () => {
    setup();

    expect(
      findGroupMembersApp()
        .props('loadingEl')
        .isSameNode(loadingEl),
    ).toBe(true);
  });
});
