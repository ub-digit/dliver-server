# config valid only for current version of Capistrano
lock '3.4.0'

# Set the application name
set :application, 'dLiver'

# Set the repository link
set :repo_url, 'git@github.com:ub-digit/dLiver.git'

# Set tmp directory on remote host - Default value: '/tmp , which often will not allow files to be executed
set :tmp_dir, '/home/rails/tmp'

# Copy originals into /{app}/shared/config from respective sample file
set :linked_files, %w{config/database.yml config/config_secret.yml config/passwd}

set :rvm_ruby_string, :local              # use the same ruby as used locally for deployment

# Forces user to assign a valid tag for deploy
#def get_tag
#  all_tags = `git tag`.split("\n")
#
#  ask :answer, "Tag to deploy (make sure to push the tag first): #{all_tags} "
#  tag = fetch(:answer)
#  if !all_tags.include? tag
#    abort "Tag #{tag} is not a valid value"
#  end
#  tag
#end

#set :branch, get_tag # Sets branch according to given tag
