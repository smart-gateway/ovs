# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   ovs::virtual_port { 'namevar': }
define ovs::virtual_port (
  String  $ensure    = 'present',
  String  $port_name = undef,
  Integer $port_vlan = 0,
  String  $vswitch,
) {

  # Use the $name variable as the port_name if not specified
  if !$port_name {
    $port_name = $name
  }

  # Check the action type
  $ensure_created = $ensure ? {
    'installed' => true,
    'present'   => true,
    'disabled'  => true,
    default     => false,
  }

  if $ensure_created {
    # Create a tap interface
    exec { "create a tap interface for port ${port_name}":
      command => "ip tuntap add mode tap ${port_name}",
      path    => $::ovs::path,
      unless  => "ethtool -i ${port_name} | grep -q 'driver: tun'",
    }

    # Create tag if vlan is set
    $tag_arg = $port_vlan ? {
      0 => "",
      default => "tag=${port_vlan}"
    }

    # Add port to vswitch
    exec { "add port ${port_vlan} ${tag_arg} to ${vswitch}":
      command => "ovs-vsctl add-port ${vswitch} ${port_name} ${tag_arg}",
      path    => $::ovs::path,
      unless  => "ovs-vsctl port-to-br ${port_name}",
    }

    # Set the tap interface to up if not disabled
    if $ensure != 'disabled' {
      exec { "set the virtual interface port ${port_name} status to up":
        command => "ip link set dev ${port_name} up",
        path    => $::ovs::path,
        unless  => "ip link show ${port} | grep -q ',UP'",
      }
    } else {
      exec { "set the virtual interface port ${port_name} status to down":
        command => "ip link set dev ${port_name} down",
        path    => $::ovs::path,
        onlyif  => "ip link show ${port} | grep -q ',UP'",
      }
    }

  } else {
    # Remove port from vswitch
    exec { "remove port ${port_name} ${tag_arg} on ${vswitch}":
      command => "ovs-vsctl del-port ${vswitch} ${port_name}",
      path    => $::ovs::path,
      onlyif  => "ovs-vsctl port-to-br ${port_name}",
    }

    # Remove the tap interface
    exec { "remove tap interface for port ${port_name}":
      command => "ip link delete ${port_name}",
      path    => $::ovs::path,
      onlyif  => "ethtool -i ${port_name} | grep -q 'driver: tun'",
    }
  }
}