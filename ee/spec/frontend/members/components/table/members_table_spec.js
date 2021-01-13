import { within } from '@testing-library/dom';
import { mount, createLocalVue, createWrapper } from '@vue/test-utils';
import Vuex from 'vuex';
import { member as memberMock, members } from 'jest/members/mock_data';
import MembersTable from '~/members/components/table/members_table.vue';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('MemberList', () => {
  let wrapper;

  const createStore = (state = {}) => {
    return new Vuex.Store({
      state: {
        members: [],
        tableFields: [],
        tableAttrs: {
          table: { 'data-qa-selector': 'members_list' },
          tr: { 'data-qa-selector': 'member_row' },
        },
        sourceId: 1,
        currentUserId: 1,
        ...state,
      },
    });
  };

  const createComponent = (state) => {
    wrapper = mount(MembersTable, {
      localVue,
      store: createStore(state),
      stubs: [
        'member-avatar',
        'member-source',
        'expires-at',
        'created-at',
        'member-action-buttons',
        'role-dropdown',
        'remove-group-link-modal',
        'expiration-datepicker',
      ],
    });
  };

  const getByTestId = (id, options) =>
    createWrapper(within(wrapper.element).getByTestId(id, options));
  const findTableCellByMemberId = (tableCellLabel, memberId) =>
    getByTestId(`members-table-row-${memberId}`).find(
      `[data-label="${tableCellLabel}"][role="cell"]`,
    );

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('fields', () => {
    describe('"Actions" field', () => {
      const memberCanOverride = {
        ...memberMock,
        source: { ...memberMock.source, id: 1 },
        canOverride: true,
      };

      const memberNoPermissions = {
        ...memberMock,
        id: 2,
      };

      describe('when one of the members has `canOverride` permissions', () => {
        it('renders the "Actions" field', () => {
          createComponent({
            members: [memberNoPermissions, memberCanOverride],
            tableFields: ['actions'],
          });

          expect(within(wrapper.element).queryByTestId('col-actions')).not.toBe(null);

          expect(
            findTableCellByMemberId('Actions', memberNoPermissions.id).classes(),
          ).toStrictEqual(['col-actions', 'gl-display-none!', 'gl-display-lg-table-cell!']);
          expect(findTableCellByMemberId('Actions', memberCanOverride.id).classes()).toStrictEqual([
            'col-actions',
          ]);
        });
      });

      describe('when none of the members have `canOverride` permissions', () => {
        it('does not render the "Actions" field', () => {
          createComponent({ members, tableFields: ['actions'] });

          expect(within(wrapper.element).queryByTestId('col-actions')).toBe(null);
        });
      });
    });
  });
});
