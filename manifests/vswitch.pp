# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   ovs::vswitch { 'namevar': }
define ovs::vswitch(
  String        $ensure = 'present',
  Array[String] $physical_ports,
  Array[Hash]   $virtual_ports,
){

  # Check the action type
  $ensure_created = $ensure ? {
    'installed' => true,
    'present'   => true,
    'disabled'  => true,
    default     => false,
  }

  if $ensure_created {
    # Create the ovs switch
    exec { "create openvswitch ${name}":
      command => "ovs-vsctl add-br ${name}",
      path    => $::ovs::path,
      unless  => "ovs-vsctl br-exists ${name}",
    }

    # Create physical ports
    $physical_ports.each | Integer $index, String $port | {
      # Add port to the ovs switch
      ovs::physical_port { "create phsyical port ${port}":
        ensure    => $ensure,
        port_name => $port,
        vswitch   => $name,
      }
    }

    # Create virtual ports
    $virtual_ports.each | Integer $index, Hash $port | {
      ovs::virtual_port { "create virtual port ${port[name]}":
        ensure    => $ensure,
        port_name => $port[name],
        port_vlan => $port[vlan],
        vswitch   => $name,
      }
    }

    # Set the switch to up unless it is disabled
    if $ensure != 'disabled' {
      exec { 'set the virtual switchstatus to up':
        command => "ip link set dev ${name} up",
        path    => $::ovs::path,
        unless  => "ip link show ${name} | grep -q ',UP'",
      }
    } else {
      exec { 'set the virtual switch status to down':
        command => "ip link set dev ${name} down",
        path    => $::ovs::path,
        onlyif  => "ip link show ${name} | grep -q ',UP'",
      }
    }

  } else {
    # Remove physical ports from the ovs switch
    $physical_ports.each | Integer $index, String $port | {
      ovs::physical_port { "remove phsyical port ${port} from ${name}":
        ensure    => $ensure,
        port_name => $port,
        vswitch   => $name,
      }
    }

    # Remove virtual ports from the ovs switch
    $virtual_ports.each | Integer $index, String $port | {
      ovs::virtual_port { "remove virtual port ${port[name]}":
        ensure    => $ensure,
        port_name => $port[name],
        port_vlan => $port[vlan],
        vswitch   => $name,
      }
    }
    # Remove the ovs switch
    exec { "remove openvswitch ${name}":
      command => "ovs-vsctl del-br ${name}",
      path    => $::ovs::path,
      onlyif  => "ovs-vsctl br-exists ${name}",
    }
  }
}
