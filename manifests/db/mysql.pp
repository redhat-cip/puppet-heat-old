# The heat::db::mysql class creates a MySQL database for heat.
# It must be used on the MySQL server
#
# == Parameters
#
#  [*password*]
#    password to connect to the database. Mandatory.
#
#  [*dbname*]
#    name of the database. Optional. Defaults to heat.
#
#  [*user*]
#    user to connect to the database. Optional. Defaults to heat.
#
#  [*host*]
#    the default source host user is allowed to connect from.
#    Optional. Defaults to 'localhost'
#
#  [*allowed_hosts*]
#    other hosts the user is allowd to connect from.
#    Optional. Defaults to undef.
#
#  [*charset*]
#    the database charset. Optional. Defaults to 'latin1'
#
class heat::db::mysql(
  $password      = false,
  $dbname        = 'heat',
  $user          = 'heat',
  $host          = 'localhost',
  $allowed_hosts = undef,
  $charset       = 'latin1',
) {

  validate_string($password)

  Class['mysql::server'] -> Class['heat::db::mysql']
  Class['heat::db::mysql'] -> Exec<| title == 'heat-manage db_sync' |>
  Database[$dbname] ~> Exec<| title == 'heat-manage db_sync' |>

  mysql::db { $dbname:
    user         => $user,
    password     => $password,
    host         => $host,
    charset      => $charset,
    require      => Class['mysql::config'],
  }

  if $allowed_hosts {
    heat::db::mysql::host_access { $allowed_hosts:
      user      => $user,
      password  => $password,
      database  => $dbname,
    }
  }
}
