include_recipe "aws"

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