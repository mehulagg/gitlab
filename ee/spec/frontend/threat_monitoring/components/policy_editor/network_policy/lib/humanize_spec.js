import {
  EndpointMatchModeAny,
  EndpointMatchModeLabel,
  PortMatchModePortProtocol,
  RuleDirectionOutbound,
  RuleTypeEntity,
  RuleTypeCIDR,
  RuleTypeFQDN,
  humanizeNetworkPolicy,
  buildRule,
} from 'ee/threat_monitoring/components/policy_editor/network_policy/lib';

describe('humanizeNetworkPolicy', () => {
  let policy;
  let rule;

  beforeEach(() => {
    rule = buildRule();
    policy = {
      name: 'test-policy',
      endpointMatchMode: EndpointMatchModeAny,
      endpointLabels: '',
      rules: [rule],
    };
  });

  describe('without rules', () => {
    beforeEach(() => {
      policy.rules = [];
    });

    it('returns policy description', () => {
      expect(humanizeNetworkPolicy(policy)).toEqual('Deny all traffic');
    });
  });

  it('returns policy description', () => {
    expect(humanizeNetworkPolicy(policy)).toEqual(
      'Allow all inbound traffic to <strong>all</strong> pods ' +
        'from <strong>all</strong> pods ' +
        'on <strong>any</strong> port',
    );
  });

  describe('with endpoint labels', () => {
    beforeEach(() => {
      policy.endpointMatchMode = EndpointMatchModeLabel;
      policy.endpointLabels = 'one two:value two:another';
    });

    it('returns policy description', () => {
      expect(humanizeNetworkPolicy(policy)).toEqual(
        'Allow all inbound traffic to pods <strong>[one: , two: another]</strong> ' +
          'from <strong>all</strong> pods ' +
          'on <strong>any</strong> port',
      );
    });
  });

  describe('with additional egress rule', () => {
    beforeEach(() => {
      const anotherRule = buildRule();
      anotherRule.direction = RuleDirectionOutbound;
      policy.rules.push(anotherRule);
    });

    it('returns policy description', () => {
      expect(humanizeNetworkPolicy(policy)).toEqual(
        'Allow all inbound traffic to <strong>all</strong> pods from <strong>all</strong> pods on <strong>any</strong> port' +
          '<br><br>AND<br><br>' +
          'Allow all outbound traffic from <strong>all</strong> pods to <strong>all</strong> pods on <strong>any</strong> port',
      );
    });
  });

  describe('with ports', () => {
    beforeEach(() => {
      rule.portMatchMode = PortMatchModePortProtocol;
      rule.ports = '80 81/udp invalid';
    });

    it('returns policy description', () => {
      expect(humanizeNetworkPolicy(policy)).toEqual(
        'Allow all inbound traffic to <strong>all</strong> pods ' +
          'from <strong>all</strong> pods ' +
          'on ports <strong>80/TCP, 81/UDP</strong>',
      );
    });
  });

  describe('with endpoint rule', () => {
    beforeEach(() => {
      rule.matchLabels = 'one two:value two:another';
    });

    it('returns policy description', () => {
      expect(humanizeNetworkPolicy(policy)).toEqual(
        'Allow all inbound traffic to <strong>all</strong> pods ' +
          'from pods <strong>[one: , two: another]</strong> ' +
          'on <strong>any</strong> port',
      );
    });
  });

  describe('with entity rule', () => {
    beforeEach(() => {
      rule = buildRule(RuleTypeEntity);
      rule.entities = ['host', 'world'];
      policy.rules = [rule];
    });

    it('returns policy description', () => {
      expect(humanizeNetworkPolicy(policy)).toEqual(
        'Allow all inbound traffic to <strong>all</strong> pods ' +
          'from <strong>host, world</strong> ' +
          'on <strong>any</strong> port',
      );
    });
  });

  describe('with cidr rule', () => {
    beforeEach(() => {
      rule = buildRule(RuleTypeCIDR);
      rule.cidr = '0.0.0.0/32 1.1.1.1/24';
      policy.rules = [rule];
    });

    it('returns policy description', () => {
      expect(humanizeNetworkPolicy(policy)).toEqual(
        'Allow all inbound traffic to <strong>all</strong> pods ' +
          'from <strong>0.0.0.0/32, 1.1.1.1/24</strong> ' +
          'on <strong>any</strong> port',
      );
    });
  });

  describe('with fqdn rule', () => {
    beforeEach(() => {
      rule = buildRule(RuleTypeFQDN);
      rule.fqdn = 'some-service.com another-service.com';
      policy.rules = [rule];
    });

    it('returns policy description', () => {
      expect(humanizeNetworkPolicy(policy)).toEqual(
        'Allow all inbound traffic to <strong>all</strong> pods ' +
          'from <strong>some-service.com, another-service.com</strong> ' +
          'on <strong>any</strong> port',
      );
    });
  });
});
