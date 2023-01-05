# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include ovs::install
class ovs::install {
  if $::ovs::package_manage {

    # Ensure ethtool is installed
    package { 'ensure that required ovs module package ethtool is installed':
      name   => 'ethtool',
      ensure => present,
    }

    # Set the name of the package based on if dpdk is enabled
    $ovs_package = $::ovs::dpdk_enable ? {
      true    => 'openvswitch-switch-dpdk',
      default => 'openvswitch-switch'
    }

    # Ensure that the switch package is in the desired state
    package { "ensure that the ${ovs_package} package is ${ovs::package_ensure}":
      name   => $ovs_package,
      ensure => $::ovs::package_ensure,
    }

    # Ensure that the tools are in the desired state
    package { "ensure that the openvswitch-common package is ${ovs::tools_ensure}":
      name   => 'openvswitch-common',
      ensure => $::ovs::tools_ensure,
    }
  }
}
