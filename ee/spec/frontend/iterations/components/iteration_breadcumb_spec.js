import { mount } from '@vue/test-utils';
import { nextTick } from 'vue';

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

  const mountComponent = () => {
    router = createRouter({ base, permissions });
    wrapper = mount(component, {
      router,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  it('contains only a single link to list', () => {
    mountComponent();
    const links = wrapper.findAll('a');

    expect(links).toHaveLength(1);
    expect(links.at(0).attributes('href')).toBe(base);
  });

  it('links to new cadence form page', async () => {
    mountComponent();
    router.push({ name: 'new' });

    await nextTick();

    const links = wrapper.findAll('a');

    expect(links).toHaveLength(2);
    expect(links.at(0).attributes('href')).toBe(base);
    expect(links.at(1).attributes('href')).toBe('/new');
  });

  it('links to edit cadence form page', () => {
    const cadenceId = 1234;
    router.push({ name: 'edit', params: { cadenceId } });
    mountComponent();
    const links = wrapper.findAll('a');

    expect(links).toHaveLength(3);
    expect(links.at(0).attributes('href')).toBe(base);
    expect(links.at(1).attributes('href')).toBe(`/${cadenceId}`);
    expect(links.at(2).attributes('href')).toBe(`/${cadenceId}/edit`);
  });

  it('links to iteration page', async () => {
    const cadenceId = 1234;
    const iterationId = 4567;
    mountComponent();
    router.push({ name: 'iteration', params: { cadenceId, iterationId } });
    await nextTick();
    const links = wrapper.findAll('a');

    expect(links).toHaveLength(4);
    expect(links.at(0).attributes('href')).toBe(base);
    expect(links.at(1).attributes('href')).toBe(`/${cadenceId}`);
    expect(links.at(2).attributes('href')).toBe(`/${cadenceId}/iterations`);
    expect(links.at(3).attributes('href')).toBe(`/${cadenceId}/iterations/${iterationId}`);
  });

  it('links to edit iteration page', async () => {
    const cadenceId = 1234;
    const iterationId = 4567;
    mountComponent();
    router.push({ name: 'editIteration', params: { cadenceId, iterationId } });

    await nextTick();

    const links = wrapper.findAll('a');

    expect(links).toHaveLength(5);
    expect(links.at(0).attributes('href')).toBe(base);
    expect(links.at(1).attributes('href')).toBe(`/${cadenceId}`);
    expect(links.at(2).attributes('href')).toBe(`/${cadenceId}/iterations`);
    expect(links.at(3).attributes('href')).toBe(`/${cadenceId}/iterations/${iterationId}`);
    expect(links.at(4).attributes('href')).toBe(`/${cadenceId}/iterations/${iterationId}/edit`);
  });
});
