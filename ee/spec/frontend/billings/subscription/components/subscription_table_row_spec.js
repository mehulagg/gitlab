import { shallowMount } from '@vue/test-utils';
import { GlIcon } from '@gitlab/ui';
import SubscriptionTableRow from 'ee/billings/subscriptions/components/subscription_table_row.vue';
import createStore from 'ee/billings/stores/index_subscriptions';
import Popover from '~/vue_shared/components/help_popover.vue';
import { dateInWords } from '~/lib/utils/datetime_utility';

describe('subscription table row', () => {
  let store;
  let wrapper;

  const header = {
    icon: 'monitor',
    title: 'Test title',
  };

  const columns = [
    {
      id: 'a',
      label: 'Column A',
      value: 100,
      colClass: 'number',
    },
    {
      id: 'b',
      label: 'Column B',
      value: 200,
      popover: {
        content: 'This is a tooltip',
      },
    },
  ];

  const billableSeatsHref = 'http://billable/seats';

  const defaultProps = { header, columns, billableSeatsHref };

  const createComponent = ({ props = {}, billableMembersFeatureFlagEnabled = true } = {}) => {
    store = createStore();
    jest.spyOn(store, 'dispatch').mockImplementation();

    wrapper = shallowMount(SubscriptionTableRow, {
      propsData: {
        ...defaultProps,
        ...props,
      },
      provide: {
        glFeatures: { apiBillableMemberList: billableMembersFeatureFlagEnabled },
      },
      store,
    });
  };

  beforeEach(() => {
    createComponent();
  });

  const findHeaderCell = () => wrapper.find('[data-testid="header-cell"]');
  const findContentCells = () => wrapper.findAll('[data-testid="content-cell"]');
  const findHeaderIcon = () => findHeaderCell().find(GlIcon);

  it('dispatches correct actions when created', () => {
    expect(store.dispatch).toHaveBeenCalledWith(
      'subscription/fetchHasBillableGroupMembers',
      undefined,
    );
  });

  it(`should render one header cell and ${columns.length} visible columns in total`, () => {
    expect(findHeaderCell().exists()).toBe(true);
    expect(findContentCells().length).toBe(columns.length);
  });

  it(`should not render a hidden column`, () => {
    const hiddenColIdx = columns.find(c => !c.display);
    const hiddenCol = findContentCells().at(hiddenColIdx);

    expect(hiddenCol).toBe(undefined);
  });

  it('should render a title in the header cell', () => {
    expect(findHeaderCell().element.textContent).toMatch(header.title);
  });

  it(`should render a ${header.icon} icon in the header cell`, () => {
    expect(findHeaderIcon().exists()).toBe(true);
    expect(findHeaderIcon().props('name')).toBe(header.icon);
  });

  columns.forEach((col, idx) => {
    it(`should render label and value in column ${col.label}`, () => {
      const currentCol = findContentCells().at(idx);

      expect(currentCol.find('[data-testid="property-label"]').element.textContent).toMatch(
        col.label,
      );

      expect(currentCol.find('[data-testid="property-value"]').element.textContent).toMatch(
        String(col.value),
      );
    });
  });

  it('should append the "number" css class to property value in "Column A"', () => {
    const currentCol = findContentCells().at(0);

    expect(
      currentCol.find('[data-testid="property-value"]').element.classList.contains('number'),
    ).toBe(true);
  });

  it('should render an info icon in "Column B"', () => {
    const currentCol = findContentCells().at(1);

    expect(currentCol.find(Popover).exists()).toBe(true);
  });

  describe('date column', () => {
    const dateColumn = {
      id: 'c',
      label: 'Column C',
      value: '2018-01-31',
      isDate: true,
    };

    beforeEach(() => {
      createComponent({ props: { columns: [dateColumn] } });
    });

    it('should render the date in UTC', () => {
      const currentCol = findContentCells().at(0);

      const d = dateColumn.value.split('-');
      const outputDate = dateInWords(new Date(d[0], d[1] - 1, d[2]));

      expect(currentCol.find('[data-testid="property-label"]').element.textContent).toMatch(
        dateColumn.label,
      );

      expect(currentCol.find('[data-testid="property-value"]').element.textContent).toMatch(
        outputDate,
      );
    });
  });

  describe('seats in use usage button', () => {
    const findUsageButton = () =>
      findContentCells()
        .at(0)
        .find('[data-testid="seats-usage-button"]');

    it('is rendered when column id is correct and has href set', () => {
      createComponent({ props: { columns: [{ id: 'seatsInUse' }] } });

      Object.assign(store.state.subscription, { hasBillableGroupMembers: true });

      return wrapper.vm.$nextTick().then(() => {
        expect(findUsageButton().exists()).toBe(true);
        expect(findUsageButton().attributes('href')).toBe(billableSeatsHref);
      });
    });

    it('is not rendered if col id does not have correct value', () => {
      createComponent({ props: { columns: [{ id: 'some_value' }] } });

      Object.assign(store.state.subscription, { hasBillableGroupMembers: true });

      return wrapper.vm.$nextTick().then(() => {
        expect(findUsageButton().exists()).toBe(false);
      });
    });

    it('is not rendered if feature flag is not set', () => {
      createComponent({
        props: { columns: [{ id: 'seatsInUse' }] },
        billableMembersFeatureFlagEnabled: false,
      });

      Object.assign(store.state.subscription, { hasBillableGroupMembers: true });

      return wrapper.vm.$nextTick().then(() => {
        expect(findUsageButton().exists()).toBe(false);
      });
    });

    it('is not rendered if subscription has no billable members', () => {
      createComponent({
        props: { columns: [{ id: 'seatsInUse' }] },
      });

      Object.assign(store.state.subscription, { hasBillableGroupMembers: false });

      return wrapper.vm.$nextTick().then(() => {
        expect(findUsageButton().exists()).toBe(false);
      });
    });

    it('is not rendered if billable seats href is not provided', () => {
      createComponent({ props: { columns: [{ id: 'seatsInUse' }], billableSeatsHref: '' } });

      Object.assign(store.state.subscription, { hasBillableGroupMembers: true });

      return wrapper.vm.$nextTick().then(() => {
        expect(findUsageButton().exists()).toBe(false);
      });
    });
  });
});
