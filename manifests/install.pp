# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include ovs::install
class ovs::install {
  if $ovs::package_manage {

    # Set the name of the package based on if dpdk is enabled
    $ovs_package = $::ovs::dpdk_enable ? {
      true    => 'openvswitch-switch-dpdk',
      default => 'openvswitch-switch'
    }

    # Ensure that the switch package is in the desired state
    package { 'ensure that the switch component of openvswitch is in the desired state':
      name   => $ovs_package,
      ensure => $package_ensure,
    }

    # Ensure that the tools are in the desired state
    package { 'ensure that the common vswitch components are in the desired state':
      name   => 'openvswitch-common',
      ensure => $tools_ensure,
    }
  }
}
