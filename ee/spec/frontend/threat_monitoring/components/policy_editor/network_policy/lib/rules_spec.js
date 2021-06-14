import {
  RuleTypeEndpoint,
  RuleTypeEntity,
  RuleTypeCIDR,
  RuleTypeFQDN,
  RuleDirectionInbound,
  RuleDirectionOutbound,
  PortMatchModeAny,
  PortMatchModePortProtocol,
  EntityTypes,
  buildRule,
} from 'ee/threat_monitoring/components/policy_editor/network_policy/lib';
import { ruleSpec } from 'ee/threat_monitoring/components/policy_editor/network_policy/lib/rules';

describe('buildRule', () => {
  const oldRule = {
    direction: RuleDirectionOutbound,
    portMatchMode: PortMatchModePortProtocol,
    ports: '80/tcp',
  };

  describe.each([RuleTypeEndpoint, RuleTypeEntity, RuleTypeCIDR, RuleTypeFQDN])(
    'buildRule $ruleType',
    (ruleType) => {
      it('builds correct instance', () => {
        const rule = buildRule(ruleType);
        expect(rule).toMatchObject({
          ruleType,
          direction: RuleDirectionInbound,
          portMatchMode: PortMatchModeAny,
          ports: '',
        });
      });

      describe('with oldRule', () => {
        it('builds correct instance', () => {
          const rule = buildRule(ruleType, oldRule);
          expect(rule).toMatchObject({
            ruleType,
            direction: RuleDirectionOutbound,
            portMatchMode: PortMatchModePortProtocol,
            ports: '80/tcp',
          });
        });
      });
    },
  );
});

describe('ruleSpec', () => {
  let rule;

  function testPortMatchers() {
    describe('given rule has port matchers', () => {
      beforeEach(() => {
        rule.portMatchMode = PortMatchModePortProtocol;
        rule.ports = '80 81/tcp 82/udp invalid';
      });

      it('includes correct toPorts block', () => {
        expect(ruleSpec(rule)).toMatchObject({
          toPorts: [
            {
              ports: [
                { port: '80', protocol: 'TCP' },
                { port: '81', protocol: 'TCP' },
                { port: '82', protocol: 'UDP' },
              ],
            },
          ],
        });
      });
    });
  }

  describe('RuleTypeEndpoint', () => {
    beforeEach(() => {
      rule = buildRule(RuleTypeEndpoint);
    });

    it('returns empty matchLabels', () => {
      expect(ruleSpec(rule)).toEqual({
        fromEndpoints: [
          {
            matchLabels: {},
          },
        ],
      });
    });

    testPortMatchers();

    describe('with match labels', () => {
      beforeEach(() => {
        rule.matchLabels = 'one two:val three: two:overwrite four: five';
      });

      it('returns correct spec', () => {
        expect(ruleSpec(rule)).toEqual({
          fromEndpoints: [
            {
              matchLabels: {
                one: '',
                two: 'overwrite',
                three: '',
                five: '',
                four: '',
              },
            },
          ],
        });
      });

      testPortMatchers();
    });

    describe('with outbound direction', () => {
      beforeEach(() => {
        rule.direction = RuleDirectionOutbound;
        rule.matchLabels = 'foo:bar';
      });

      it('returns correct spec', () => {
        expect(ruleSpec(rule)).toEqual({
          toEndpoints: [{ matchLabels: { foo: 'bar' } }],
        });
      });

      testPortMatchers();
    });
  });

  describe('RuleTypeEntity', () => {
    beforeEach(() => {
      rule = buildRule(RuleTypeEntity);
    });

    it('returns empty spec', () => {
      expect(ruleSpec(rule)).toEqual({});
    });

    testPortMatchers();

    describe('with entities', () => {
      beforeEach(() => {
        rule.entities = [EntityTypes.HOST, EntityTypes.WORLD];
      });

      it('returns correct spec', () => {
        expect(ruleSpec(rule)).toEqual({
          fromEntities: [EntityTypes.HOST, EntityTypes.WORLD],
        });
      });

      testPortMatchers();
    });

    describe('with outbound direction', () => {
      beforeEach(() => {
        rule.direction = RuleDirectionOutbound;
        rule.entities = [EntityTypes.HOST];
      });

      it('returns correct spec', () => {
        expect(ruleSpec(rule)).toEqual({
          toEntities: [EntityTypes.HOST],
        });
      });

      testPortMatchers();
    });
  });

  describe('RuleTypeCIDR', () => {
    beforeEach(() => {
      rule = buildRule(RuleTypeCIDR);
    });

    it('returns empty spec', () => {
      expect(ruleSpec(rule)).toEqual({});
    });

    testPortMatchers();

    describe('with cidr masks', () => {
      beforeEach(() => {
        rule.cidr = '0.0.0.0/24 1.1.1.1/32';
      });

      it('returns correct spec', () => {
        expect(ruleSpec(rule)).toEqual({
          fromCIDR: ['0.0.0.0/24', '1.1.1.1/32'],
        });
      });

      testPortMatchers();
    });

    describe('with outbound direction', () => {
      beforeEach(() => {
        rule.direction = RuleDirectionOutbound;
        rule.cidr = '0.0.0.0/24';
      });

      it('returns correct spec', () => {
        expect(ruleSpec(rule)).toEqual({ toCIDR: ['0.0.0.0/24'] });
      });

      testPortMatchers();
    });
  });

  describe('RuleTypeFQDN', () => {
    beforeEach(() => {
      rule = buildRule(RuleTypeFQDN);
    });

    it('returns empty spec', () => {
      expect(ruleSpec(rule)).toEqual({});
    });

    testPortMatchers();

    describe('with fqdn', () => {
      beforeEach(() => {
        rule.fqdn = 'some-service.com another-service.com';
      });

      it('returns empty spec', () => {
        expect(ruleSpec(rule)).toEqual({});
      });

      testPortMatchers();
    });

    describe('with outbound direction', () => {
      beforeEach(() => {
        rule.direction = RuleDirectionOutbound;
        rule.fqdn = 'some-service.com another-service.com';
      });

      it('returns correct spec', () => {
        expect(ruleSpec(rule)).toEqual({
          toFQDNs: [{ matchName: 'some-service.com' }, { matchName: 'another-service.com' }],
        });
      });

      testPortMatchers();
    });
  });
});
