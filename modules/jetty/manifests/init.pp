class jetty {

    $version="8.1.6"
    $build_number="v20120903"
    $port="9000"

    file { '/usr/local/jetty': ensure => directory; }

    file { '/usr/sbin/install-jetty':
         owner => root,
         mode => 0700,
         content => template("jetty/install-jetty"),
         ensure => present;
    }

    exec { 'install-jetty':
         name => '/usr/sbin/install-jetty',
         unless => "ls /usr/local/jetty/jetty-hightide-${version}.${build_number}",
         timeout => 0,
         path => ['/bin', '/usr/sbin', '/usr/bin'],
         require => File['/usr/sbin/install-jetty', '/usr/local/jetty'],
         notify  => File['config-file']
    }

    file { 'config-file':
         name => "/usr/local/jetty/jetty-hightide-${version}.${build_number}/etc/jetty.xml",
         owner => "root",
         group => "root",
         mode => 0644,
         content => template("jetty/jetty.xml"),
         notify  => Exec["start-jetty"]
    }

    exec { 'start-jetty':
         cwd => "/usr/local/jetty/jetty-hightide-${version}.${build_number}",         
         command => "/usr/bin/java  -jar start.jar &",
         path => ['/bin', '/usr/sbin', '/usr/bin'],
         require => [Exec['install-jetty'],File['config-file']]
    }

}

