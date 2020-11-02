import sys
import json

data = json.load(sys.stdin)
for src, alerts in data.items():
    for a in alerts:
        print('{0}:\n Line {1}, position {2}: ({3}):\n {4}: {5}\n To fix: {6}\n'.format(
            src,
            a['Line'],
            a['Span'][0],
            a['Check'],
            a['Severity'],
            a['Message'],
            a['Link']))