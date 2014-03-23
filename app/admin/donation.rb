ActiveAdmin.register Donation do
  permit_params :user_id, :email, :currency, :cents, :anonymous, :donated_at, :donation_goal_id, :base_cents
end
