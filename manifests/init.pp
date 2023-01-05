# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include ovs
class ovs(
  Boolean $package_manage = true,
  String $package_ensure = 'present',
  String $tools_ensure = 'present',
  Boolean $dpdk_enable = false,
  String $service_name = 'openvswitch-switch.service',
  Array[String] $path = ['/usr/local/sbin','/usr/local/bin','/usr/sbin','/usr/bin','/sbin','/bin'],
) {

  # Ensure class declares subordinate classes
  contain ovs::install
  contain ovs::config
  contain ovs::service

  # Order operations
  anchor { '::ovs::begin': }
  -> Class['::ovs::install']
  -> Class['::ovs::config']
  -> Class['::ovs::service']
  -> anchor { '::ovs::end': }
}
