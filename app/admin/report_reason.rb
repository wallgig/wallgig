ActiveAdmin.register ReportReason do
  config.filters = false

  menu parent: 'Reports'

  permit_params :reportable_type, :reason
end
