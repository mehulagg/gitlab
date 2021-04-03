import { shallowMount } from '@vue/test-utils';
import mixin from 'ee/vue_shared/security_reports/mixins/security_report_mixin';

describe('securityReportMixin', () => {
  it.each`
    key                     | link
    ${'sast'}               | ${'http://fake.url/sast/help/path'}
    ${'containerScanning'}  | ${'http://fake.url/container/scanning/help/path'}
    ${'dast'}               | ${'http://fake.url/dast/help/path'}
    ${'dependencyScanning'} | ${'http://fake.url/dependency/scanning/help/path'}
  `('generates correct external link with icon', ({ key, link }) => {
    // Create a fake component for the mixin with the mock help path data value.
    const component = {
      render() {},
      data: () => ({ [`${key}HelpPath`]: link }), // 'key' -> 'keyHelpPath'
      mixins: [mixin],
    };

    // Mount the component so that the mixin's computed properties are evaluated.
    const { vm } = shallowMount(component);

    // Get the link that the mixin generated.
    const mixinLink = vm[`${key}Popover`].content; // 'key' -> 'keyPopover'

    // Check that for each link, the expected strings exist.
    expect(mixinLink).toContain(`href="${link}`);
    expect(mixinLink).toContain('target="_blank"');
    expect(mixinLink).toContain('rel="noopener noreferrer"');
    expect(mixinLink).toContain('external-link');
  });
});
