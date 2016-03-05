# Sets up the webserver

include_recipe 'apt'

# add the deadsnakes ppa
# note: this is no longer necessary, since we're no longer using HTTPS
# requests in Flask, since it's behind an ELB anyway.
# apt_repository "deadsnakes" do
#   uri "http://ppa.launchpad.net/fkrull/deadsnakes-python2.7/ubuntu"
#   distribution 'trusty'
#   components ["main"]
#   keyserver "keyserver.ubuntu.com"
#   key "FF3997E83CD969B409FB24BC5BB92C09DB82666C"
# end

include_recipe "aws"
# # install all the required system packages

# # omitting python-sympy due to the time it takes to install.
package 'python2.7'
package ['python-dev', 'python-pip', 'python-numpy', 'python-scipy', 'python-matplotlib', 'ipython', 'ipython-notebook', 'python-pandas', 'python-nose', 'git', 'openssl', 'libffi-dev']

include_recipe 'poise-python'

# ---- MTURK REPO KEYS & GITHUB ---- #
# get the necessary keys for github
aws_s3_file "#{node[:home]}/.ssh/#{node[:mturk_deploy_key]}.pem" do
  bucket node[:serving_key_bucket]
  remote_path "#{node[:mturk_deploy_key]}.pem"
  aws_access_key_id node[:aws][:access_key_id]
  aws_secret_access_key node[:aws][:secret_access_key]
  # mode "0600"
end

aws_s3_file "#{node[:home]}/.ssh/#{node[:mturk_deploy_key]}.pub" do
  bucket node[:serving_key_bucket]
  remote_path "#{node[:mturk_deploy_key]}.pub"
  aws_access_key_id node[:aws][:access_key_id]
  aws_secret_access_key node[:aws][:secret_access_key]
  #mode '0600'
end

file "#{node[:home]}/.ssh/#{node[:mturk_deploy_key]}.pub" do
    mode "0600"
end

file "#{node[:home]}/.ssh/#{node[:mturk_deploy_key]}.pem" do
    mode "0600"
end

template "#{node[:home]}/#{node[:mturk_deploy_key]}-wrap-ssh4git.sh" do
  source "wrap-ssh4git.sh.erb"
  mode "0755"
  variables({:ssh_key => "#{node[:home]}/.ssh/#{node[:mturk_deploy_key]}.pem"})
end

# clone the required directories
git node[:mturk_repo] do
    repository "git@github.com:neon-lab/mturk_task_v2.git"
    action :sync
    revision 'master'
    ssh_wrapper "#{node[:home]}/#{node[:mturk_deploy_key]}-wrap-ssh4git.sh"
end

# ---- BOTO REPO KEYS & GITHUB ---- #
# get the necessary keys for github
aws_s3_file "#{node[:home]}/.ssh/#{node[:boto_deploy_key]}.pem" do
  bucket node[:serving_key_bucket]
  remote_path "#{node[:boto_deploy_key]}.pem"
  aws_access_key_id node[:aws][:access_key_id]
  aws_secret_access_key node[:aws][:secret_access_key]
  # mode "0600"
end

aws_s3_file "#{node[:home]}/.ssh/#{node[:boto_deploy_key]}.pub" do
  bucket node[:serving_key_bucket]
  remote_path "#{node[:boto_deploy_key]}.pub"
  aws_access_key_id node[:aws][:access_key_id]
  aws_secret_access_key node[:aws][:secret_access_key]
  #mode '0600'
end

file "#{node[:home]}/.ssh/#{node[:boto_deploy_key]}.pub" do
    mode "0600"
end

file "#{node[:home]}/.ssh/#{node[:boto_deploy_key]}.pem" do
    mode "0600"
end

template "#{node[:home]}/#{node[:boto_deploy_key]}-wrap-ssh4git.sh" do
  source "wrap-ssh4git.sh.erb"
  mode "0755"
  variables({:ssh_key => "#{node[:home]}/.ssh/#{node[:boto_deploy_key]}.pem"})
end

git node[:boto_repo] do
    repository "git@github.com:neon-lab/boto.git"
    action :sync
    revision 'updates_WSDL_mturk'
    ssh_wrapper "#{node[:home]}/#{node[:boto_deploy_key]}-wrap-ssh4git.sh"
end

execute "install_boto" do
  command "sudo pip install -e #{node[:boto_repo]}"
end

# install the pip requirements
pip_requirements "#{node[:mturk_repo]}/requirements.txt"

# download the GeoIP2 Lite repository
aws_s3_file "#{node[:mturk_repo]}/#{node[:geoip_file]}" do
  bucket node[:webserver_assets_bucket]
  remote_path node[:geoip_file]
  # i don't think we still need to use the aws_access_keys and stuff, since the machine itself has permissions. we'll have to find out.
end

# create a LOG directory
directory "#{node[:home]}/mturk_logs" do
  action :create
  owner 'ubuntu'
  mode '0775'
end