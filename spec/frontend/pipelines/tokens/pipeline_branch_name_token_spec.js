import Api from '~/api';
import { GlFilteredSearchToken, GlFilteredSearchSuggestion, GlLoadingIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import PipelineBranchNameToken from '~/pipelines/components/tokens/pipeline_branch_name_token.vue';
import { branches, mockBranchesAfterMap } from '../mock_data';

describe('Pipeline Branch Name Token', () => {
  let wrapper;

  const findFilteredSearchToken = () => wrapper.find(GlFilteredSearchToken);
  const findAllFilteredSearchSuggestions = () => wrapper.findAll(GlFilteredSearchSuggestion);
  const findLoadingIcon = () => wrapper.find(GlLoadingIcon);

  const stubs = {
    GlFilteredSearchToken: {
      template: `<div><slot name="suggestions"></slot></div>`,
    },
  };

  const defaultProps = {
    config: {
      type: 'ref',
      icon: 'branch',
      title: 'Branch name',
      dataType: 'ref',
      unique: true,
      branches,
      projectId: '21',
    },
    value: {
      data: '',
    },
  };

  const createComponent = (options, data) => {
    wrapper = shallowMount(PipelineBranchNameToken, {
      propsData: {
        ...defaultProps,
      },
      data() {
        return {
          ...data,
        };
      },
      ...options,
    });
  };

  beforeEach(() => {
    jest.spyOn(Api, 'branches').mockResolvedValue({ data: branches });

    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('passes config correctly', () => {
    expect(findFilteredSearchToken().props('config')).toEqual(defaultProps.config);
  });

  it('fetches and sets project branches', () => {
    expect(Api.branches).toHaveBeenCalled();

    expect(wrapper.vm.branches).toEqual(mockBranchesAfterMap);
    expect(findLoadingIcon().exists()).toBe(false);
  });

  describe('displays loading icon correctly', () => {
    it('shows loading icon', () => {
      createComponent({ stubs }, { loading: true });

      expect(findLoadingIcon().exists()).toBe(true);
    });

    it('does not show loading icon', () => {
      createComponent({ stubs }, { loading: false });

      expect(findLoadingIcon().exists()).toBe(false);
    });
  });

  describe('shows branches correctly', () => {
    it('renders all trigger authors', () => {
      createComponent({ stubs }, { branches, loading: false });

      // should have length of all branches plus the static 'master' option
      expect(findAllFilteredSearchSuggestions()).toHaveLength(branches.length + 1);
    });

    it('renders only the branch searched for', () => {
      const mockBranches = ['branch-1'];
      createComponent({ stubs }, { branches: mockBranches, loading: false });

      // should have length of branch searched for plus the static 'master' option
      expect(findAllFilteredSearchSuggestions()).toHaveLength(mockBranches.length + 1);
    });
  });
});
