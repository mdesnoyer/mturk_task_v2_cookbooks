include_recipe 'poise-python'

python_runtime "fuck_chef" do
    version "2.7.11"
    action :install
end

# execute "install_boto" do
#   command "sudo pip install -e #{node[:boto_repo]}"
# end

# # install the pip requirements
# pip_requirements "#{node[:mturk_repo]}/requirements.txt"