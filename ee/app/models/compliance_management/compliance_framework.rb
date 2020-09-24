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
  end
end
