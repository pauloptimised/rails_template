gem_group :development, :test do
  gem 'rspec-rails' # , '~> 3.4'
  gem 'factory_girl_rails' # , '~> 4.5.0'
  gem 'shoulda-matchers' # , '~> 2.8.0'
end

gem_group :test do
  gem 'database_cleaner' # , '~> 1.5.0'
  gem 'capybara' # , '~> 2.5.0'
  gem 'launchy' # , '~> 2.4.3'
  # gem 'poltergeist', '~> 1.6.0'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'shoulda-callback-matchers' # , '~> 1.1.1'
end

gem_group :development do
  gem 'guard-rspec' # , '~> 4.6.4', require: false
  gem 'optimadmin_generators', git: 'git@github.com:eskimosoup/optimadmin_generators.git'
  gem 'rack-mini-profiler' # , '~> 0.9.7'
  gem 'flamegraph' # , '~> 0.1.0'
  gem 'stackprof' # , '~> 0.2.7'
  gem 'bullet' # , '~> 4.14.7'
end

gem 'optimadmin', git: 'git@github.com:eskimosoup/Optimadmin.git', branch: 'master'
gem 'friendly_id' # , '~> 5.1.0'
gem 'therubyracer', platforms: :ruby

# gsub_file 'Gemfile', "gem 'spring'", "# gem 'spring'"

# route "root to: 'application#index'"

# inject_into_file 'app/controllers/application_controller.rb', after: 'protect_from_forgery with: :exception' do
#  <<-RUBY
#  \n
#  def index
#  end
# RUBY
# end

# the empty lines are necessary
inject_into_file 'config/database.yml', after: "database: #{app_name}_test" do
  <<-RUBY
  \n
  host: 192.168.0.41
  username: postgres
  password: tmedia
RUBY
end

# the empty lines are necessary
# http://www.rubydoc.info/github/wycats/thor/master/Thor/Actions#insert_into_file-instance_method
# :force => true for insert two or more times the same content.
inject_into_file 'config/database.yml', after: "database: #{app_name}_development", force: true do
  <<-RUBY
  \n
  host: 192.168.0.41
  username: postgres
  password: tmedia
RUBY
end

application(nil, env: 'development') do
  <<-RUBY
  config.logger = ActiveSupport::Logger.new(config.paths['log'].first, 1, 5_242_880)

  Rack::MiniProfiler.config.position = 'right' # ALT + P will toggle visibility

  Rails.application.routes.default_url_options[:host] = 'localhost:3000'
  config.web_console.whitelisted_ips = '192.168.0.0/16'
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: 'mail.eskimosoup.co.uk',
    authentication: :plain,
    user_name: 'tasks@eskimosoup.co.uk',
    password: 'poipoip',
    enable_starttls_auto: false
  }

  config.generators do |g|
    g.assets false
    g.javascripts  false
    g.stylesheets  false
  end
RUBY
end

application(nil, env: 'test') do
  <<-RUBY
  Rails.application.routes.default_url_options[:host] = 'localhost:3000'
RUBY
end

application(nil, env: 'production') do
  <<-RUBY
  config.logger = ActiveSupport::Logger.new(config.paths['log'].first, 5, 26_214_400)

  Rails.application.routes.default_url_options[:host] = 'www.ludo5.co.uk'

  # config.action_mailer.delivery_method = :sendmail
  # config.action_mailer.sendmail_settings = {
  #  location: '/usr/lib/sendmail',
  #  arguments: '-i'
  # }

  config.action_mailer.smtp_settings = { enable_starttls_auto: false }

  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    address: 'mail.optimised.today',
    authentication: :plain,
    user_name: 'noreply@optimised.today',
    password: 'LudoStudio47#!poip'
  }
RUBY
end

run 'bundle install'

after_bundle do
  remove_dir 'test'
  rake 'optimadmin:install:migrations'
  # Generator hangs if you don't stop spring
  run 'spring stop'
  generate 'rspec:install'
  generate 'optimadmin:site_settings'
  generate 'optimadmin:install'
  generate 'optimadmin:error_messages'
  generate 'friendly_id'

  append_to_file 'config/initializers/assets.rb', 'Rails.application.config.assets.precompile += %w( optimadmin/* )'
  environment env: 'development' do
    <<-RUBY
    config.after_initialize do
      Bullet.enable = true
      Bullet.bullet_logger = true
      Bullet.console = true
      Bullet.rails_logger = true
      Bullet.add_footer = true
    end
  RUBY
  end

  rake 'db:create'
  rake 'db:create', env: 'test'
  rake 'db:migrate'
  rake 'db:migrate', env: 'test'

  git :init
  git add: '.'
  git commit: "-a -m 'Initial commit'"
end
