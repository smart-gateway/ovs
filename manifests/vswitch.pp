# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   ovs::vswitch { 'namevar': }
define ovs::vswitch(
  String $ensure = 'present',
  Array[String] $ports,
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

    $ports.each | Integer $index, String $port | {
      # Add port to the ovs switch
      ovs::physical_port { "create phsyical port ${port}":
        port_name => $port,
        vswitch   => $name,
        ensure    => $ensure,
      }
      # exec { "add port ${port} to ${name}":
      #   command => "ovs-vsctl add-port ${name} ${port}",
      #   path    => $::ovs::path,
      #   unless  => "ovs-vsctl port-to-br ${port}",
      # }
      #
      # if $ensure != 'disabled' {
      #   # Enable the port
      #   exec { "enable ovs switch ${name} port ${port}":
      #     command => "ip link set dev ${port} up",
      #     path    => $::ovs::path,
      #     unless  => "ip link show ${port} | grep -q ',UP'",
      #   }
      # } else {
      #   # Disable the port
      #   exec { "disable ovs switch ${name} port ${port}":
      #     command => "ip link set dev ${port} down",
      #     path    => $::ovs::path,
      #     onlyif  => "ip link show ${port} | grep -q ',UP'",
      #   }
      # }
    }
  } else {
    # Remove ports from the ovs switch
    $ports.each | Integer $index, String $port | {
      ovs::physical_port { "remove phsyical port ${port} from ${name}":
        port_name => $port,
        vswitch   => $name,
        ensure    => $ensure,
      }
      # exec { "del port ${port} on ${name}":
      #   command => "ovs-vsctl del-port ${name} ${port}",
      #   path    => $::ovs::path,
      #   onlyif  => "ovs-vsctl port-to-br ${port}"
      # }
    }

    # Remove the ovs switch
    exec { "remove openvswitch ${name}":
      command => "ovs-vsctl del-br ${name}",
      path    => $::ovs::path,
      onlyif  => "ovs-vsctl br-exists ${name}",
    }
  }
}
