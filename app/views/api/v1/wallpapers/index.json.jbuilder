json.partial! 'api/v1/shared/paging', collection: @wallpapers

json.wallpapers @wallpapers, partial: 'api/v1/wallpapers/wallpaper', as: :wallpaper
