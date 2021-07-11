import { mount } from '@vue/test-utils';
import component from 'ee/iterations/components/iteration_breadcrumb.vue';
import createRouter from 'ee/iterations/router';

describe('Iteration Breadcrumb', () => {
  let router;
  let wrapper;

  const base = '/';
  const permissions = {
    canCreateCadence: true,
    canEditCadence: true,
    canCreateIteration: true,
    canEditIteration: true,
  };
  const cadenceId = 1234;
  const iterationId = 4567;

  const mountComponent = () => {
    router = createRouter({ base, permissions });
    wrapper = mount(component, {
      router,
    });
  };

  beforeEach(() => {
    mountComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    router = null;
  });

  it('contains only a single link to list', () => {
    const links = wrapper.findAll('a');
    expect(links).toHaveLength(1);
    expect(links.at(0).attributes('href')).toBe(base);
  });

  it('links to new cadence form page', async () => {
    await router.push({ name: 'new' });

    const links = wrapper.findAll('a');
    expect(links).toHaveLength(2);
    expect(links.at(0).attributes('href')).toBe(base);
    expect(links.at(1).attributes('href')).toBe('/new');
  });

  it('links to edit cadence form page', async () => {
    await router.push({ name: 'edit', params: { cadenceId } });

    const links = wrapper.findAll('a');
    expect(links).toHaveLength(3);
    expect(links.at(2).attributes('href')).toBe(`/${cadenceId}/edit`);
  });

  it('links to iteration page', async () => {
    await router.push({ name: 'iteration', params: { cadenceId, iterationId } });

    const links = wrapper.findAll('a');
    expect(links).toHaveLength(4);
    expect(links.at(2).attributes('href')).toBe(`/${cadenceId}/iterations`);
    expect(links.at(3).attributes('href')).toBe(`/${cadenceId}/iterations/${iterationId}`);
  });

  it('links to edit iteration page', async () => {
    await router.push({ name: 'editIteration', params: { cadenceId, iterationId } });

    const links = wrapper.findAll('a');
    expect(links).toHaveLength(5);
    expect(links.at(4).attributes('href')).toBe(`/${cadenceId}/iterations/${iterationId}/edit`);
  });

  it('links to new iteration page', async () => {
    await router.push({ name: 'newIteration', params: { cadenceId } });

    const links = wrapper.findAll('a');
    expect(links).toHaveLength(4);
    expect(links.at(3).attributes('href')).toBe(`/${cadenceId}/iterations/new`);
  });
});
