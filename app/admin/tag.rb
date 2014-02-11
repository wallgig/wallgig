ActiveAdmin.register Tag, as: 'Tag' do
  config.filters = false

  permit_params :name, :slug, :category_id

  scope :all, default: true
  scope :pending_approval
  scope :approved

  batch_action :approve do |selection|
    Tag.find(selection).each do |tag|
      tag.approve_by!(current_user)
    end
    redirect_to :back, notice: 'Tags were successfully approved.'
  end

  batch_action :unapprove do |selection|
    Tag.find(selection).each(&:unapprove!)
    redirect_to :back, notice: 'Tags were successfully unapproved.'
  end

  index do
    selectable_column
    id_column
    column(:name) { |tag| span tag.name, class: "purity-#{tag.purity}" }
    column('Approved') { |tag| status_tag tag.approved? ? 'Yes' : 'No' }
    column :slug
    column :category
    column :coined_by
    column :approved_by
    column :approved_at
    column :created_at
    column :updated_at
    default_actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :slug
      f.input :category
    end
    f.actions
  end

  controller do
    def scoped_collection
      Tag.includes(:category, :coined_by, :approved_by)
    end

    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end
end
