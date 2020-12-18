# restic rest server class

class restic::rest_server (
  String $version = '0.10.0',
  String $arch = 'linux_amd64',
  String $bin_dir = '/usr/local/bin',
  String $service_name = 'rest-server',
  String $service_user = 'restic',
  String $service_group = 'restic',
  String $backups_path = '/tmp/restic',
  String $server_parameters = '',
  Boolean $service_active = true,
  Boolean $service_enable = true,
) {
  archive { "/tmp/rest-server-${version}.tar.gz":
    ensure          => present,
    extract         => true,
    extract_path    => '/opt',
    source          => "https://github.com/restic/rest-server/releases/download/v${version}/rest-server_${version}_${arch}.tar.gz",
    checksum_verify => false,
    creates         => "/opt/rest-server_${version}_${arch}/rest-server",
    cleanup         => true,
    extract_command => $prometheus::extract_command,
  }
  -> file { "/opt/rest-server_${version}_${arch}/rest-server":
    owner => 'root',
    group => 'root',
    mode  => '0555'
  }
  -> file { "${bin_dir}/rest-server":
    ensure => link,
    notify => Service[$service_name],
    target => "/opt/rest-server_${version}_${arch}/rest-server",
  }

  ~> systemd::unit_file { "${service_name}.service":
   content => "puppet:///modules/${module_name}/rest-server.service.erb",
   enable => true,
   active => true,
  }
}