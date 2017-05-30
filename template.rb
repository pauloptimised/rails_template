gem_group :development do
  gem 'optimadmin_generators', git: 'git@github.com:eskimosoup/optimadmin_generators.git'
end

gem 'optimadmin', git: 'git@github.com:eskimosoup/Optimadmin.git', branch: 'master'

application(nil, env: 'production') do
  <<-RUBY
  config.action_mailer.smtp_settings = { enable_starttls_auto: false }

  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    address: 'mail.optimised.today',
    authentication: :plain,
    user_name: 'noreply@optimised.today',
    password: ENV['NOREPLY_PASSWORD']
  }
RUBY
end

run 'bundle install'

after_bundle do
  rake 'optimadmin:install:migrations'
  # Generator hangs if you don't stop spring
  run 'spring stop'
  generate 'optimadmin:site_settings'
  generate 'optimadmin:install'
  generate 'optimadmin:error_messages'

  append_to_file 'config/initializers/assets.rb', 'Rails.application.config.assets.precompile += %w( optimadmin/* )'
end
