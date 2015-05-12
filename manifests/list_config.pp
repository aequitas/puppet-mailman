define mailman::list_config(
  $variable,
  $value,
  $mlist,
  $ensure = present,
) {

  if !defined(Concat["/var/lib/mailman/lists/${mlist}/puppet-config.conf"]) {
    concat {"/var/lib/mailman/lists/${mlist}/puppet-config.conf":
      owner => root,
      group => root,
      mode  => '0644',
    }
  }

  concat::fragment {$name:
    ensure  => $ensure,
    target  => "/var/lib/mailman/lists/${mlist}/puppet-config.conf",
    content => template('mailman/config_list.erb'),
    require => [Class['mailman'], Maillist[$mlist]],
  } ~>
  exec {"load configuration ${variable} on ${mlist}":
    refreshonly => true,
    command     => "config_list -i /var/lib/mailman/lists/${mlist}/puppet-config.conf ${mlist}",
    path        => "/bin:/sbin:/usr/bin:/usr/sbin",
    onlyif      => "config_list -i /var/lib/mailman/lists/${mlist}/puppet-config.conf -c ${mlist}",
  }
}
