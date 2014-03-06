json.id @wallpaper.id

# Quick way to calculate newfavourites count without reload
json.fav_count @wallpaper.favourites_count + (@fav_status ? 1 : -1)
json.fav_status @fav_status
