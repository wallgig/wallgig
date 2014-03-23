ActiveAdmin.register DonationGoal do
  menu parent: 'Donations'
  permit_params :name, :starts_on, :ends_on, :cents
end
