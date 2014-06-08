# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'wallgig'
set :repo_url, 'https://github.com/wallgig/wallgig.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/srv/www/wallgig.net'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml .env}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 10

namespace :puma do
  desc 'Start puma'
  task :start do
    on roles(:app), in: :sequence do
      execute :sudo, '/etc/init.d/puma-wallgig.net', 'start'
    end
  end

  desc 'Restart puma'
  task :restart do
    on roles(:app), in: :sequence do
      execute :sudo, '/etc/init.d/puma-wallgig.net', 'restart'
    end
  end

  desc 'Stop puma'
  task :stop do
    on roles(:app), in: :sequence do
      execute :sudo, '/etc/init.d/puma-wallgig.net', 'stop'
    end
  end
end


namespace :sidekiq do
  desc 'Start sidekiq'
  task :start do
    on roles(:app), in: :sequence do
      execute :sudo, '/etc/init.d/sidekiq-wallgig.net', 'start'
    end
  end

  desc 'Restart sidekiq'
  task :restart do
    on roles(:app), in: :sequence do
      execute :sudo, '/etc/init.d/sidekiq-wallgig.net', 'restart'
    end
  end

  desc 'Stop sidekiq'
  task :stop do
    on roles(:app), in: :sequence do
      execute :sudo, '/etc/init.d/sidekiq-wallgig.net', 'stop'
    end
  end
end


namespace :wallpaper do
  desc 'Reindex wallpaper'
  task :reindex do
    on roles(:app), in: :sequence do
      within release_path do
        with rails_env: :production do
          execute :rake, 'searchkick:reindex', 'CLASS=Wallpaper'
        end
      end
    end
  end
end


namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Restart mechanism
      Rake::Task["sidekiq:restart"].invoke
      Rake::Task["puma:restart"].invoke
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      within release_path do
        execute :rake, 'cache:clear'
      end
    end
  end
end
