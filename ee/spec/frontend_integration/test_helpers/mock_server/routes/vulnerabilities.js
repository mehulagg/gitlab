import { mockIssueLink } from '../../mock_data/vulnerabilities_mock_data';

export default (server) => {
  server.get('/api/v4/vulnerabilities/:id/issue_links', () => [mockIssueLink]);
};
