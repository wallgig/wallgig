ActiveAdmin.register Wallpaper do
  config.filters = false

  permit_params :purity, :tag_list, :source, :image_gravity

  scope :pending_approval, default: true
  scope :processing
  Wallpaper.purity.options.each do |label, value|
    scope(label) { |w| w.approved.processed.with_purities(value) }
  end
  scope :all

  Wallpaper.purity.options.each do |label, value|
    batch_action :"mark_#{value}" do |selection|
      Wallpaper.find(selection).each do |wallpaper|
        wallpaper.purity = value
        wallpaper.save
      end
      redirect_to :back, notice: "Wallpapers were successfully marked as #{label}."
    end
  end

  batch_action :approve do |selection|
    Wallpaper.find(selection).each do |wallpaper|
      wallpaper.approve_by!(current_user)
    end
    redirect_to :back, notice: 'Wallpapers were successfully approved.'
  end

  batch_action :reindex do |selection|
    Wallpaper.find(selection).each &:update_index
    redirect_to :back, notice: 'Wallpaper indices were successfully updated.'
  end

  batch_action :reprocess do |selection|
    Wallpaper.find(selection).each &:queue_create_thumbnails
    Wallpaper.find(selection).each &:queue_process_image
    redirect_to :back, notice: 'Wallpapers were successfully queued for reprocessing.'
  end

  index do
    selectable_column
    column 'Id', sortable: :id do |wallpaper|
      link_to wallpaper.id, admin_wallpaper_path(wallpaper)
    end
    column 'Thumbnail' do |wallpaper|
      link_to admin_wallpaper_path(wallpaper) do
        if wallpaper.thumbnail_image.present?
          image_tag wallpaper.thumbnail_image.url, width: 125, height: 94
        else
          'Processing'
        end
      end
    end
    column 'Approved', sortable: :approved_at do |wallpaper|
      status_tag wallpaper.approved? ? 'Yes' : 'No'
    end
    column 'Purity', sortable: :purity do |wallpaper|
      status_tag wallpaper.purity_text
    end
    column :processing, sortable: :processing do |wallpaper|
      status_tag wallpaper.processing? ? 'Yes' : 'No'
    end
    column 'Tags', :cached_tag_list, sortable: false
    column 'Views', :impressions_count
    column 'Favourites', sortable: :favourites_count do |wallpaper|
      link_to wallpaper.favourites_count, admin_favourites_path(q: { wallpaper_id_eq: wallpaper })
    end
    column 'Comments', :comments_count
    column :user
    column :created_at
    column :updated_at
    actions
  end

  show do
    panel 'Wallpaper Details' do
      attributes_table_for wallpaper do
        row :user
        row(:approved) { |w| status_tag w.approved? ? 'Yes' : 'No' }
        row(:purity) { |w| status_tag w.purity_text }
        row :tag_list
        row :source
        row :primary_color do |wallpaper|
          content_tag :div, nil, style: "width: 50px; height: 50px; background-color: #{wallpaper.primary_color.to_html_hex}" if wallpaper.primary_color.present?
        end
        row :color do |wallpaper|
          ul style: 'list-style: none; padding: 0' do
            wallpaper.wallpaper_colors.map do |wallpaper_color|
              li wallpaper_color.percentage.round(2), style: "display: inline-block; width: 50px; height: 50px; background-color: #{wallpaper_color.to_html_hex}"
            end
          end
        end
        row :created_at
        row :updated_at
      end
    end
    panel 'Image' do
      attributes_table_for wallpaper do
        row :processing do |wallpaper|
          status_tag wallpaper.processing? ? 'Yes' : 'No'
        end
        row :image do
          link_to wallpaper.image.url do
            if wallpaper.thumbnail_image.present?
              image_tag wallpaper.thumbnail_image.url
            else
              'View original image'
            end
          end
        end
        row :image_uid
        row :image_name
        row :image_width
        row :image_height
        row :thumbnail_image_uid
        row :image_gravity, &:image_gravity_text
        row :phash do |wallpaper|
          content_tag :code, wallpaper.phash
        end
        row :scrape_source
        row :scrape_id
      end
    end
    panel 'Stats' do
      attributes_table_for wallpaper do
        row :impressions_count
        row :favourites_count
        row :comments_count
      end
    end
    if wallpaper.similar_wallpapers.any?
      panel 'Similar Images' do
        table_for wallpaper.similar_wallpapers do
          column :thumbnail do |similar_wallpaper|
            link_to admin_wallpaper_path(similar_wallpaper) do
              if similar_wallpaper.thumbnail_image.present?
                image_tag similar_wallpaper.thumbnail_image.url
              else
                "Wallpaper \##{similar_wallpaper.id}"
              end
            end
          end
        end        
      end
    end
    active_admin_comments
  end

  form do |f|
    f.inputs do
      f.input :purity
      f.input :tag_list
      f.input :source
      f.input :image_gravity
    end
    f.actions
  end

  member_action :merge_wallpaper do
    @wallpaper = Wallpaper.find(params[:id])
  end

  member_action :perform_wallpaper_merge, method: :post do
    @from_wallpaper = Wallpaper.find(params[:id])
    @to_wallpaper = Wallpaper.find(params[:target_id])
    WallpaperMerger.from(@from_wallpaper).to(@to_wallpaper).execute

    redirect_to admin_wallpaper_path(@to_wallpaper), notice: 'Wallpapers merged!'
  end

  member_action :approve_wallpaper, method: :post do
    @wallpaper = Wallpaper.find(params[:id])
    @wallpaper.approve_by!(current_user)
    redirect_to admin_wallpaper_path(@wallpaper), notice: 'Wallpaper was successfully approved.'
  end

  member_action :unapprove_wallpaper, method: :post do
    @wallpaper = Wallpaper.find(params[:id])
    @wallpaper.unapprove!
    redirect_to admin_wallpaper_path(@wallpaper), notice: 'Wallpaper was successfully unapproved.'
  end

  action_item only: :show do
    link_to 'Merge Wallpaper', merge_wallpaper_admin_wallpaper_path(wallpaper)
  end

  action_item only: :show do
    if wallpaper.approved?
      link_to 'Unapprove', unapprove_wallpaper_admin_wallpaper_path(wallpaper), data: { method: :post, confirm: 'Are you sure?' }
    else
      link_to 'Approve', approve_wallpaper_admin_wallpaper_path(wallpaper), data: { method: :post, confirm: 'Are you sure?' }
    end
  end

  controller do
    def scoped_collection
      Wallpaper.includes(:user)
    end
  end
end