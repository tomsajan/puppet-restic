# @summary Installs restic
#
# This class will install restic on the node
#
# @example
#   include restic
class restic(
  $version             = '0.11.0',
  $checksum            = 'f559e774c91f1201ffddba74d5758dec8342ad2b50a3bcd735ccb0c88839045c',
  $checksum_type       = 'sha256',
  $arch                = 'amd64',
  $default_environment = [],
) {
  archive { '/tmp/restic.bz2':
    ensure          => present,
    extract         => true,
    extract_path    => '/usr/local/bin',
    extract_command => 'bunzip2 -c %s > /usr/local/bin/restic',
    source          => "https://github.com/restic/restic/releases/download/v${version}/restic_${version}_linux_${arch}.bz2",
    checksum        => $checksum,
    checksum_type   => $checksum_type,
    cleanup         => true,
    creates         => '/usr/local/bin/restic',
    require         => Package['bzip2'],
  }
  -> file { '/usr/local/bin/restic':
    ensure => file,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }
  file { '/var/log/restic':
    ensure => directory,
  }
  file { '/usr/local/bin/restic_backup.sh':
    ensure  => file,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    content => file("${module_name}/restic_backup.sh"),
  }
  file { '/etc/logrotate.d/restic':
    ensure  => file,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => file("${module_name}/logrotate.restic"),
  }
  ensure_packages(['bzip2', 'jq'], {'ensure' => 'present'})
}
