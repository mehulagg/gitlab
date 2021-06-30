import { GlLabel } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import ComplianceFrameworkLabel from 'ee/vue_shared/components/compliance_framework_label/compliance_framework_label.vue';
import { complianceFramework } from './mock_data';

describe('ComplianceFrameworkLabel component', () => {
  let wrapper;
  const propsData = { ...complianceFramework };

  const findLabel = () => wrapper.findComponent(GlLabel);

  beforeEach(() => {
    wrapper = shallowMount(ComplianceFrameworkLabel, {
      propsData,
    });
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('has the correct props', () => {
    const { color: backgroundColor, description, name: title } = propsData;

    expect(findLabel().props()).toMatchObject({
      backgroundColor,
      description,
      size: 'sm',
      title,
    });
  });
});
