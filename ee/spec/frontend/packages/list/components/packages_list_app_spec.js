import { shallowMount } from '@vue/test-utils';
import { GlEmptyState } from '@gitlab/ui';
import PackageListApp from 'ee/packages/list/components/packages_list_app.vue';

describe('packages_list_app', () => {
  let wrapper;

  const emptyListHelpUrl = 'helpUrl';
  const findListComponent = () => wrapper.find({ name: 'package-list' });
  const findLoadingComponent = () => wrapper.find({ name: 'gl-loading-icon' });

  const componentConfig = {
    stubs: {
      GlEmptyState,
      'package-list': {
        name: 'package-list',
        template: '<div><slot name="empty-state"></slot></div>',
      },
      'gl-loading-icon': { name: 'gl-loading-icon', template: '<div>loading</div>' },
    },
    computed: {
      isLoading: () => false,
      emptyListIllustration: () => 'helpSvg',
      emptyListHelpUrl: () => emptyListHelpUrl,
      resourceId: () => 'project_id',
    },
    methods: {
      requestPackagesList: jest.fn(),
      requestDeletePackage: jest.fn(),
      setProjectId: jest.fn(),
      setGroupId: jest.fn(),
      setUserCanDelete: jest.fn(),
    },
  };

  beforeEach(() => {
    wrapper = shallowMount(PackageListApp, componentConfig);
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders', () => {
    expect(wrapper.element).toMatchSnapshot();
  });

  describe('when isLoading is true', () => {
    beforeEach(() => {
      wrapper = shallowMount(PackageListApp, {
        ...componentConfig,
        computed: {
          isLoading: () => true,
        },
      });
    });
    it('shows the loading component', () => {
      const loader = findLoadingComponent();
      expect(loader.exists()).toBe(true);
    });
  });

  it('generate the correct empty list link', () => {
    const emptyState = findListComponent();
    const link = emptyState.find('a');

    expect(link.html()).toMatchInlineSnapshot(
      `"<a href=\\"${emptyListHelpUrl}\\" target=\\"_blank\\">publish and share your packages</a>"`,
    );
  });

  it('call requestPackagesList on page:changed', () => {
    const list = findListComponent();
    list.vm.$emit('page:changed', 1);
    expect(componentConfig.methods.requestPackagesList).toHaveBeenCalledWith({ page: 1 });
  });

  it('call requestDeletePackage on package:delete', () => {
    const list = findListComponent();
    list.vm.$emit('package:delete', 1);
    expect(componentConfig.methods.requestDeletePackage).toHaveBeenCalledWith({
      projectId: 'project_id',
      packageId: 1,
    });
  });
});
