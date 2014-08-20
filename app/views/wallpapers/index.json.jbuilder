json.partial! 'shared/api/paging', collection: @wallpapers

json.data @wallpapers, partial: 'wallpaper', as: :wallpaper
