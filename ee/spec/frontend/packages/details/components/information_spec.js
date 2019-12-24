import { shallowMount } from '@vue/test-utils';
import PackageInformation from 'ee/packages/details/components/information.vue';
import ClipboardButton from '~/vue_shared/components/clipboard_button.vue';

describe('PackageInformation', () => {
  let wrapper;

  const defaultProps = {
    information: [
      {
        label: 'Information one',
        value: 'Information value one',
      },
      {
        label: 'Information two',
        value: 'Information value two',
      },
      {
        label: 'Information three',
        value: 'Information value three',
      },
    ],
  };

  function createComponent(props = {}) {
    const propsData = {
      ...defaultProps,
      ...props,
    };

    wrapper = shallowMount(PackageInformation, {
      sync: false,
      propsData,
    });
  }

  const headingSelector = () => wrapper.find('.card-header > strong');
  const copyButton = () => wrapper.findAll(ClipboardButton);
  const informationSelector = () => wrapper.findAll('ul.content-list li');
  const informationRowText = index =>
    informationSelector()
      .at(index)
      .text();

  afterEach(() => {
    if (wrapper) wrapper.destroy();
  });

  it('renders the information block with default heading', () => {
    createComponent();

    expect(headingSelector()).toExist();
    expect(headingSelector().text()).toBe('Package information');
  });

  it('renders a custom supplied heading', () => {
    const heading = 'A custom heading';

    createComponent({
      heading,
    });

    expect(headingSelector()).toExist();
    expect(headingSelector().text()).toBe(heading);
  });

  it('renders the supplied information', () => {
    createComponent();

    expect(informationSelector().length).toBe(3);
    expect(informationRowText(0)).toContain('one');
    expect(informationRowText(1)).toContain('two');
    expect(informationRowText(2)).toContain('three');
  });

  describe('copy button', () => {
    it('does not render by default', () => {
      createComponent();

      expect(copyButton().exists()).toBe(false);
    });

    it('does render when the prop is set and has correct text set', () => {
      createComponent({ showCopy: true });

      expect(copyButton().length).toBe(3);
      expect(copyButton().at(0).vm.text).toBe(defaultProps.information[0].value);
      expect(copyButton().at(1).vm.text).toBe(defaultProps.information[1].value);
      expect(copyButton().at(2).vm.text).toBe(defaultProps.information[2].value);
    });
  });
});
