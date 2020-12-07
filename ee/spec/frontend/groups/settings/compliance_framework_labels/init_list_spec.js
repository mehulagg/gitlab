import { createWrapper } from '@vue/test-utils';
import initComplianceFrameworkLabelsList from 'ee/groups/settings/compliance_framework_labels/init_list';
import ComplianceFrameworkLabelsList from 'ee/groups/settings/compliance_framework_labels/components/list.vue';

describe('initComplianceFrameworkLabelsList', () => {
  const emptyStateSvgPath = 'dir/image.svg';
  const groupPath = 'group-1';
  let wrapper;
  let el;

  const findList = () => wrapper.find(ComplianceFrameworkLabelsList);

  beforeEach(() => {
    el = document.createElement('div');
    el.setAttribute('data-empty-state-svg-path', emptyStateSvgPath);
    el.setAttribute('data-group-path', groupPath);

    document.body.appendChild(el);

    wrapper = createWrapper(initComplianceFrameworkLabelsList(el));
  });

  afterEach(() => {
    document.body.innerHTML = '';
    el = null;
    wrapper.destroy();
    wrapper = null;
  });

  it('parses and passes the `emptyStateSvgPath` prop', () => {
    expect(findList().props('emptyStateSvgPath')).toBe(emptyStateSvgPath);
  });

  it('parses and passes the `groupPath` prop', () => {
    expect(findList().props('groupPath')).toBe(groupPath);
  });
});
