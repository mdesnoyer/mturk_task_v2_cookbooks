# INSTANTIATING THE DATABASE INSTANCE
#
# This won't really set up the database server; instead, we assume that it is
# being built from a extant image. Instead, what we need to do is mount the
# EBS volume and attach it to /data, and then start Thrift.

include_recipe 'aws'
aws = data_bag_item('aws', 'main')

directory '/data' do
  mode '0775'
end

devices = Dir.glob('/dev/xvd?')
devices = ['/dev/xvdf'] if devices.empty?
devid = devices.sort.last[-1,1].succ

node.set_unless[:aws][:ebs_volume][:data_volume][:device] = "/dev/xvd#{devid}"
device_id = node[:aws][:ebs_volume][:data_volume][:device]


aws_ebs_volume 'data_volume' do
  action [:attach]
end

# wait for the drive to attach, before making a filesystem
ruby_block "sleeping_data_volume" do
  block do
    timeout = 0
    until File.blockdev?(device_id) || timeout == 1000
      Chef::Log.debug("device #{device_id} not ready - sleeping 10s")
      timeout += 10
      sleep 10
    end
  end
end

# create a filesystem
execute 'mkfs' do
  command "mkfs -t ext4 #{device_id}"
end

mount '/data' do
  device device_id
  fstype 'ext4'
  options 'noatime,nobootwait'
  action [:enable, :mount]
end