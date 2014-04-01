json.id @wallpaper.id

# Quick way to calculate newfavourites count without reload
json.favourites_count @wallpaper.favourites_count + (@fav_status ? 1 : -1)
json.favourited @fav_status
