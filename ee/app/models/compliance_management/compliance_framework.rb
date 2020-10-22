# frozen_string_literal: true

module ComplianceManagement
  module ComplianceFramework
    FRAMEWORKS = {
      gdpr: 1,    # General Data Protection Regulation
      hipaa: 2,   # Health Insurance Portability and Accountability Act
      pci_dss: 3, # Payment Card Industry-Data Security Standard
      soc_2: 4,   # Service Organization Control 2
      sox: 5      # Sarbanes-Oxley
    }.freeze

    ENUM_FRAMEWORK_MAPPING = {
      FRAMEWORKS[:gdpr] => {
        name: 'GDPR',
        description: 'General Data Protection Regulation',
        color: '#1aaa55'
      }.freeze,
      FRAMEWORKS[:hipaa] => {
        name: 'HIPAA',
        description: 'Health Insurance Portability and Accountability Act',
        color: '#1f75cb'
      }.freeze,
      FRAMEWORKS[:pci_dss] => {
        name: 'PCI-DSS',
        description: 'Payment Card Industry-Data Security Standard',
        color: '#6666c4'
      }.freeze,
      FRAMEWORKS[:soc_2] => {
        name: 'SOC 2',
        description: 'Service Organization Control 2',
        color: '#dd2b0e'
      }.freeze,
      FRAMEWORKS[:sox] => {
        name: 'SOX',
        description: 'Sarbanes-Oxley',
        color: '#fc9403'
      }.freeze
    }.freeze
  end
end
