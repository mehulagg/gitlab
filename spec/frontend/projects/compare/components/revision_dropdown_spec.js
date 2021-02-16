import { GlDropdown } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import AxiosMockAdapter from 'axios-mock-adapter';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import RevisionDropdown from '~/projects/compare/components/revision_dropdown.vue';

const defaultProps = {
  refsProjectPath: 'some/refs/path',
  revisionText: 'Target',
  paramsName: 'from',
  paramsBranch: 'master',
};

jest.mock('~/flash');

describe('RevisionDropdown component', () => {
  let wrapper;
  let axiosMock;

  const createComponent = (props = {}) => {
    wrapper = shallowMount(RevisionDropdown, {
      propsData: {
        ...defaultProps,
        ...props,
      },
    });
  };

  beforeEach(() => {
    axiosMock = new AxiosMockAdapter(axios);
  });

  afterEach(() => {
    wrapper.destroy();
    axiosMock.restore();
  });

  const findGlDropdown = () => wrapper.find(GlDropdown);

  it('sets hidden input', () => {
    createComponent();
    expect(wrapper.find('input[type="hidden"]').attributes('value')).toBe(
      defaultProps.paramsBranch,
    );
  });

  it('update the branches on success', async () => {
    const Branches = ['branch-1', 'branch-2'];
    const Tags = ['tag-1', 'tag-2', 'tag-3'];

    axiosMock.onGet(defaultProps.refsProjectPath).replyOnce(200, {
      Branches,
      Tags,
    });

    createComponent();

    await axios.waitForAll();

    expect(wrapper.vm.branches).toEqual(Branches);
    expect(wrapper.vm.tags).toEqual(Tags);
  });

  it('shows flash message on error', async () => {
    axiosMock.onGet('some/invalid/path').replyOnce(404);

    createComponent();

    await wrapper.vm.fetchBranchesAndTags();
    expect(createFlash).toHaveBeenCalled();
  });

  describe('GlDropdown component', () => {
    it('renders props', () => {
      createComponent();
      expect(wrapper.props()).toEqual(expect.objectContaining(defaultProps));
    });

    it('display default text', () => {
      createComponent({
        paramsBranch: null,
      });
      expect(findGlDropdown().props('text')).toBe('Select branch/tag');
    });

    it('display params branch text', () => {
      createComponent();
      expect(findGlDropdown().props('text')).toBe(defaultProps.paramsBranch);
    });
  });
});
