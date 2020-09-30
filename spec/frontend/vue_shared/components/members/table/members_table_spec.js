import { mount, createLocalVue, createWrapper } from '@vue/test-utils';
import Vuex from 'vuex';
import {
  getByText as getByTextHelper,
  getByTestId as getByTestIdHelper,
} from '@testing-library/dom';
import MembersTable from '~/vue_shared/components/members/table/members_table.vue';
import MemberAvatar from '~/vue_shared/components/members/table/member_avatar.vue';
import MemberSource from '~/vue_shared/components/members/table/member_source.vue';
import * as initUserPopovers from '~/user_popovers';
import { member as memberMock, invite, accessRequest } from '../mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('MemberList', () => {
  let wrapper;

  const createStore = (state = {}) => {
    return new Vuex.Store({
      state: {
        members: [],
        tableFields: [],
        ...state,
      },
    });
  };

  const createComponent = state => {
    wrapper = mount(MembersTable, {
      localVue,
      store: createStore(state),
      stubs: ['member-avatar'],
    });
  };

  const getByText = (text, options) =>
    createWrapper(getByTextHelper(wrapper.element, text, options));

  const getByTestId = (id, options) =>
    createWrapper(getByTestIdHelper(wrapper.element, id, options));

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('fields', () => {
    it.each`
      field           | label               | member           | expectedComponent
      ${'account'}    | ${'Account'}        | ${memberMock}    | ${MemberAvatar}
      ${'source'}     | ${'Source'}         | ${memberMock}    | ${MemberSource}
      ${'granted'}    | ${'Access granted'} | ${memberMock}    | ${null}
      ${'invited'}    | ${'Invited'}        | ${invite}        | ${null}
      ${'requested'}  | ${'Requested'}      | ${accessRequest} | ${null}
      ${'expires'}    | ${'Access expires'} | ${memberMock}    | ${null}
      ${'maxRole'}    | ${'Max role'}       | ${memberMock}    | ${null}
      ${'expiration'} | ${'Expiration'}     | ${memberMock}    | ${null}
    `('renders the $label field', ({ field, label, member, expectedComponent }) => {
      createComponent({
        members: [member],
        tableFields: [field],
      });

      expect(getByText(label, { selector: '[role="columnheader"]' }).exists()).toBe(true);

      if (expectedComponent) {
        expect(
          wrapper
            .find(`[data-label="${label}"][role="cell"]`)
            .find(expectedComponent)
            .exists(),
        ).toBe(true);
      }
    });

    it('renders "Actions" field for screen readers', () => {
      createComponent({ tableFields: ['actions'] });

      const actionField = getByTestId('col-actions');

      expect(actionField.exists()).toBe(true);
      expect(actionField.classes('gl-sr-only')).toBe(true);
    });
  });

  describe('when `members` is an empty array', () => {
    it('displays a "No members found" message', () => {
      createComponent();

      expect(getByText('No members found').exists()).toBe(true);
    });
  });

  it('initializes user popovers when mounted', () => {
    const initUserPopoversMock = jest.spyOn(initUserPopovers, 'default');

    createComponent();

    expect(initUserPopoversMock).toHaveBeenCalled();
  });
});
