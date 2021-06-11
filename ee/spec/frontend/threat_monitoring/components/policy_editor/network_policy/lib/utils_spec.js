import {
  PortMatchModeAny,
  PortMatchModePortProtocol,
} from 'ee/threat_monitoring/components/policy_editor/network_policy/lib';
import {
  labelSelector,
  portSelectors,
  splitItems,
} from 'ee/threat_monitoring/components/policy_editor/network_policy/lib/utils';

describe('labelSelector', () => {
  it('returns selector map', () => {
    expect(labelSelector('one two: three:value  three:override ')).toMatchObject({
      one: '',
      two: '',
      three: 'override',
    });
  });
});

describe('portSelectors', () => {
  it('returns list of selectors', () => {
    expect(
      portSelectors({
        portMatchMode: PortMatchModePortProtocol,
        ports: '80 81/tcp  82/UDP ',
      }),
    ).toEqual([
      { port: '80', protocol: 'TCP' },
      { port: '81', protocol: 'TCP' },
      { port: '82', protocol: 'UDP' },
    ]);
  });

  describe('when port match mode is any', () => {
    it('returns empty selector', () => {
      expect(
        portSelectors({
          portMatchMode: PortMatchModeAny,
          ports: '80 81/tcp  81/UDP ',
        }),
      ).toEqual([]);
    });
  });
});

describe('splitItems', () => {
  it('returns list of entries', () => {
    expect(splitItems('10.0.0.1/32  10.0.0.1/24  ')).toEqual(['10.0.0.1/32', '10.0.0.1/24']);
  });
});
