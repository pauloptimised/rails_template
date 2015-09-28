# Usage

To apply a template, you need to provide the Rails generator with the location of the template you wish to apply using the **-m** option.  This can either be a path to a file or a URL.

    rails new blog -m ~/template.rb
    rails new blog -m http://example.com/template.rb

In this instance:

    rails new *sitename* -d postgresql -m https://raw.githubusercontent.com/eskimosoup/rails_template/master/template.rb --skip-bundle

You can use the rake task `rails:template` to apply templates to an existing Rails application.  The location of the template needs to be passed in to an environment variable named LOCATION. Again, this can either be path to a file or a URL.

    bin/rake rails:template LOCATION=~/template.rb
    bin/rake rails:template LOCATION=http://example.com/template.rb

## Example

To skip turbolinks and use postgres database

    rails new my_app_name -d postgresql -T --skip-turbolinks -m rails_template/template.rb
