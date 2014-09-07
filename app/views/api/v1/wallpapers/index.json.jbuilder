json.partial! 'api/v1/shared/paging', collection: @wallpapers

json.data @wallpapers, partial: 'wallpaper', as: :wallpaper
