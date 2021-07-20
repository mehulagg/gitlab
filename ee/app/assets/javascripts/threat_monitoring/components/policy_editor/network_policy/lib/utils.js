import { PortMatchModeAny } from './constants';

/*
 Convert space separated list of labels into a kubernetes selector.
 Expects matchLabels in format "one two:three"
*/
export function labelSelector(labels) {
  return labels.split(/\s/).reduce((acc, item) => {
    const [key, value = ''] = item.split(':');
    if (key.length === 0) return acc;

    acc[key] = value.trim();
    return acc;
  }, {});
}

/*
 Convert ports provided as a string into a kubernetes port selectors.
 Expects ports in format "80/tcp 81"
*/
export function portSelectors({ portMatchMode, ports }) {
  if (portMatchMode === PortMatchModeAny) return [];

  return ports.split(/\s/).reduce((acc, item) => {
    const [port, protocol = 'tcp'] = item.split('/');
    const portNumber = parseInt(port, 10);
    if (Number.isNaN(portNumber)) return acc;

    acc.push({ port, protocol: protocol.trim().toUpperCase() });
    return acc;
  }, []);
}

/*
 Convert whitespace separated list of items provided as a string into a list.
 Expects items in format "0.0.0.0/24 1.1.1.1/32"
*/
export function splitItems(items) {
  return items.split(/\s/).filter((item) => item.length > 0);
}
