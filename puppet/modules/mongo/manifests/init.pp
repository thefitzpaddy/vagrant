class mongo 
{
    exec 
    { 
        'mongo-10gen-key':
            command => 'sudo apt-key add /vagrant/puppet/modules/mongo/manifests/10gen-mongo-gpg-key.asc',
    }
    
    exec 
    { 
        '10gen-repo':
            command => 'echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" > /etc/apt/sources.list.d/10gen.list',
            require => Exec['mongo-10gen-key'],
            notify  => Exec['apt-get update']
    }
    
    package 
    { 
        "mongodb-10gen":
            ensure  => present,
            require => [ Exec['apt-get update'], Exec['10gen-repo'] ],
    }

    service 
    { 
        "mongodb":
            enable => true,
            ensure => running,
            require => Package["mongodb-10gen"],
    }

    exec { 'pecl-mongo-install':
        command => 'pecl install mongo',
        timeout => 3600,
        unless => "pecl info mongo",
        require => [ Package["make"], Package["build-essential"], Package["libpcre3-dev"], Package["php-pear"] ]
    }

    exec 
    { 
        'add-mongo-extension':
            command => 'echo "extension=mongo.so" >> /etc/php5/apache2/php.ini',
            require => Exec['pecl-mongo-install'],
    }

}
