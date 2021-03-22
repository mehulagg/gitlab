import { screen, within } from '@testing-library/dom';
import initBundler from 'ee/security_configuration/dast_scanner_profiles/dast_scanner_profiles_bundle';
import { waitForText } from 'helpers/wait_for_text';
import { mockIssueLink } from '../test_helpers/mock_data/vulnerabilities_mock_data';
// import { mockVulnerability } from './mock_data';

describe('Scanner Profile', () => {
  let vm;
  let container;

  const createComponent = () => {
    setFixtures('<div class="js-dast-scanner-profile-form"></div>');

    const el = document.querySelector('.js-dast-scanner-profile-form');

    const elDataSet = {
      profilesLibraryPath: 'group/project',
      projectFullPath: '/security/configuration/a',
      onDemandScansPath: '/security/configuration/b',
    };

    Object.assign(el.dataset, {
      ...elDataSet,
    });

    container.appendChild(el);

    return initBundler(el);
  };

  beforeEach(() => {
    vm = createComponent();
  });

  afterEach(() => {
    vm.$destroy();
    vm = null;
    container = null;
  });

  it("displays the vulnerability's status", () => {
    const headerBody = screen.getByTestId('vulnerability-detail-body');

    expect(within(headerBody).getByText(mockVulnerability.state)).toBeInstanceOf(HTMLElement);
  });

  it("displays the vulnerability's severity", () => {
    const severitySection = screen.getByTestId('severity');
    const severityValue = within(severitySection).getByTestId('value');

    expect(severityValue.textContent.toLowerCase()).toContain(
      mockVulnerability.severity.toLowerCase(),
    );
  });

  it("displays a heading containing the vulnerability's title", () => {
    expect(screen.getByRole('heading', { name: mockVulnerability.title })).toBeInstanceOf(
      HTMLElement,
    );
  });

  it("displays the vulnerability's description", () => {
    expect(screen.getByText(mockVulnerability.description)).toBeInstanceOf(HTMLElement);
  });

  it('displays related issues', async () => {
    const relatedIssueTitle = await waitForText(mockIssueLink.title);

    expect(relatedIssueTitle).toBeInstanceOf(HTMLElement);
  });
});
