# In development
if Rails.env.development?
  if User.all.empty?
    # Create admin user
    user = User.create!(
      email: 'admin@example.com',
      username: 'admin',
      password: 'password',
      developer: true,
      admin: true,
      moderator: true
    )

    # Confirm user
    user.confirm!

    # Create test notifications
    10.times do |number|
      Notification.create!(user_id: user.id, message: "Notification \##{number}")
    end
  end
end

screen_resolutions = [
  { category: :standard, width: 1600, height: 1200 },
  { category: :standard, width: 1400, height: 1050 },
  { category: :standard, width: 1280, height: 1024 },
  { category: :standard, width: 1280, height: 960 },
  { category: :standard, width: 1152, height: 864 },
  { category: :standard, width: 1024, height: 768 },
  { category: :standard, width: 800, height: 600 },

  { category: :widescreen, width: 3840, height: 2400 },
  { category: :widescreen, width: 3840, height: 2160 },
  { category: :widescreen, width: 3840, height: 1200 },
  { category: :widescreen, width: 2560, height: 1600 },
  { category: :widescreen, width: 2560, height: 1440 },
  { category: :widescreen, width: 2560, height: 1080 },
  { category: :widescreen, width: 2560, height: 1024 },
  { category: :widescreen, width: 2048, height: 1152 },
  { category: :widescreen, width: 1920, height: 1200 },
  { category: :widescreen, width: 1920, height: 1080 },
  { category: :widescreen, width: 1680, height: 1050 },
  { category: :widescreen, width: 1600, height: 900 },
  { category: :widescreen, width: 1440, height: 900 },
  { category: :widescreen, width: 1280, height: 800 },
  { category: :widescreen, width: 1280, height: 720 }

]

screen_resolutions.each do |screen_resolution|
  ScreenResolution.find_or_create_by!(screen_resolution)
end

forums = [
  { name: 'Site news',       color: '3AB54A', text_color: 'FFFFFF', description: 'Wallgig News and Announcements', can_post: false },
  { name: 'General',         color: '808281', text_color: 'FFFFFF' },
  { name: 'Intros',          color: '0E76BD', text_color: 'FFFFFF', description: 'Introduce yourself here! Meet new friends' },
  { name: 'Artists room',    color: 'ED207B', text_color: 'FFFFFF', description: 'Show off your latest creations here!' },
  { name: 'Requests',        color: 'F7941D', text_color: 'FFFFFF', description: 'Request for custom wallpapers, signatures, etc. here!' },
  { name: 'Gaming',          color: 'F1592A', text_color: 'FFFFFF', description: 'Discuss games here. PC, PS3/4, Xbox, MMO, anything! Join our gaming communities' },
  { name: 'Music',           color: '9EB83B', text_color: 'FFFFFF', description: 'Talk about music here. Share playlists and more!' },
  { name: 'Movies & TV',     color: '92278F', text_color: 'FFFFFF', description: 'Discuss latest movies and tv episodes' },
  { name: 'Feedback & Bugs', color: 'BF1E2E', text_color: 'FFFFFF', description: 'Report bugs, give feedback or post suggestions here' },
  { name: 'Uncategorized',   color: 'AB9364', text_color: 'FFFFFF' }
]

forums.each do |forum|
  Forum.find_or_create_by!(forum)
end
