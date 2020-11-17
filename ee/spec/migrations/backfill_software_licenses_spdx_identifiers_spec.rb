# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe BackfillSoftwareLicensesSpdxIdentifiers do
  let(:software_licenses) { table(:software_licenses) }

  describe '#up' do
    let(:javascript_default_names) { expected_identifiers_for_javascript_default_names.keys }

    let(:expected_identifiers_for_javascript_default_names) do
      {
        'AGPL-1.0' => 'AGPL-1.0',
        'AGPL-3.0' => 'AGPL-3.0',
        'Apache 2.0' => 'Apache-2.0',
        'Artistic-2.0' => 'Artistic-2.0',
        'BSD' => 'BSD-4-Clause',
        'CC0 1.0 Universal' => 'CC0-1.0',
        'CDDL-1.0' => 'CDDL-1.0',
        'CDDL-1.1' => 'CDDL-1.1',
        'EPL-1.0' => 'EPL-1.0',
        'EPL-2.0' => 'EPL-2.0',
        'GPLv2' => 'GPL-2.0',
        'GPLv3' => 'GPL-3.0',
        'ISC' => 'ISC',
        'LGPL' => 'LGPL-3.0-only',
        'LGPL-2.1' => 'LGPL-2.1',
        'MIT' => 'MIT',
        'Mozilla Public License 2.0' => 'MPL-2.0',
        'MS-PL' => 'MS-PL',
        'MS-RL' => 'MS-RL',
        'New BSD' => 'BSD-3-Clause',
        'Python Software Foundation License' => 'Python-2.0',
        'ruby' => 'Ruby',
        'Simplified BSD' => 'BSD-2-Clause',
        'WTFPL' => 'WTFPL',
        'Zlib' => 'Zlib'
      }
    end

    before do
      software_licenses.create!(javascript_default_names.map { |name| { name: name } })
    end

    it 'updates the default license names that are hardcoded in javascript' do
      expect(software_licenses.where(spdx_identifier: nil).count).to eq(javascript_default_names.count)

      migrate!

      expect(software_licenses.where(spdx_identifier: nil).count).to eq(0)
      software_licenses.find_each do |license|
        expect(license.spdx_identifier).to eql(expected_identifiers_for_javascript_default_names[license.name])
      end
    end
  end

  describe '#down' do
    it 'resets the `spdx_identifier`' do
      mit = software_licenses.create!(name: 'MIT')

      migrate!

      expect(mit.reload.spdx_identifier).to eql('MIT')

      schema_migrate_down!

      expect(mit.reload.spdx_identifier).to be_nil
    end
  end
end
