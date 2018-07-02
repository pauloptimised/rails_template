gem_group :development do
  gem 'optimadmin_generators', git: 'git@github.com:eskimosoup/optimadmin_generators.git'
end

gem 'optimadmin', git: 'git@github.com:eskimosoup/Optimadmin.git', branch: :master

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
  # Generator hangs if you don't stop spring
  run 'spring stop'
  # From optimadmin
  generate 'optimadmin:setup'
  # From optimadmin_generators
  generate 'optimadmin:install'
  rails_command('db:migrate')
end
