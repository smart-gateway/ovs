# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   ovs::physical_port { 'namevar': }
define ovs::physical_port (
  String  $ensure    = 'present',
  String  $port_name = undef,
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

    # Add port to vswitch
    exec { "add port ${port_vlan} to ${vswitch}":
      command => "ovs-vsctl add-port ${vswitch} ${port_name}",
      path    => $::ovs::path,
      unless  => "ovs-vsctl port-to-br ${port_name}",
    }

    # Set the interface to up if not disabled
    if $ensure != 'disabled' {
      exec { 'set the physical interface port status to up':
        command => "ip link set dev ${port_name} up",
        path    => $::ovs::path,
        unless  => "ip link show ${port} | grep -q ',UP'",
      }
    } else {
      exec { 'set the physical interface port status to down':
        command => "ip link set dev ${port_name} down",
        path    => $::ovs::path,
        onlyif  => "ip link show ${port} | grep -q ',UP'",
      }
    }

  } else {
    # Remove port from vswitch
    exec { "remove port ${port_name} on ${vswitch}":
      command => "ovs-vsctl del-port ${vswitch} ${port_name}",
      path    => $::ovs::path,
      onlyif  => "ovs-vsctl port-to-br ${port_name}",
    }
  }
}
