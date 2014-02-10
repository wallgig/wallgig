# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

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

categories = [
  [
    'Anime / Manga',
      [
        'Anime / Manga Characters',
        'Anime / Manga Series',
        'Anime / Manga Movies',
        'Anime / Manga Artists'
        'Hentai / Ecchi',
        'Movies',
        'Visual Novels'
      ]
  ],
  [
    'Animals',
      [
        'Amphibians',
        'Birds',
        'Domestic / Pets',
        'Dinosaurs / Extinct',
        ['Fictional Animals', ['Dragons', 'Pokemon']],
        'Fishes / Aquatic life',
        'Insects',
        'Mammals',
        'Other Animals',
        'Reptiles'
      ]
  ],
  [
    'Art / Design',
      [
        [
          'Classic',
            [
              'Illustrations',
              'Paintings',
              'Sculptures'
            ]
        ]
      ]
  ],
  [
    'Cartoons / Comics',
      [
        'Artists',
        'Characters',
        'Series'
      ]
  ]
]

def create_categories(parent = nil, categories)
  categories.each do |category|
    if category.is_a?(Array)
      category_name, children = category.shift, category.shift
    else
      category_name, children = category, []
    end
    new_category = Category.find_or_initialize_by(name: category_name)
    new_category.parent = parent
    new_category.save!
    create_categories(new_category, children)
  end
end

create_categories(nil, categories)
