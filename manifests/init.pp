# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include ovs
class ovs(
  Boolean $package_manage = true,
  String $package_ensure = 'installed',
  String $tools_ensure = 'installed',
  Boolean $dpdk_enable = false,
  String $service_name = 'openvswitch-switch.service'
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
