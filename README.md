# ((OTRS)) Community Edition Installer

Run installer in a selected container:

```
$ ./run-in-container test-centos-8-stage-3
```


## Docker Containers

### CentOS

- **test-centos-8**  
  Base CentOS 8 system built from the `centos:8.3.2011` image with systemd enabled
- **test-centos-8-stage-1**  
  CentOS 8 with Perl installed
- **test-centos-8-stage-2**  
  CentOS 8 with Perl and Apache installed
- **test-centos-8-stage-3**  
  CentOS 8 with Perl, Apache, and MariaDB installed
- **test-centos-8-stage-4**  
  CentOS 8 with Perl, Apache, MariaDB, and Perl modules required by OTRS CE installed

### Ubuntu

- **test-ubuntu-20-04**  
  Base Ubuntu 20.04 system built from the `ubuntu:20.04` image with systemd enabled
- **test-ubuntu-20-04-stage-1**  
  Ubuntu 20.04 with Apache installed
- **test-ubuntu-20-04-stage-2**  
  Ubuntu 20.04 with Apache and MariaDB installed
- **test-ubuntu-20-04-stage-3**  
  Ubuntu 20.04 with Apache, MariaDB, and Perl modules required by OTRS CE installed


## Shell Variables

Shell variables used globally:

- `SCRIPT_DIR` - the folder where the installation script is located
- `INSTALL_DIR` - installation folder (default: `/opt/otrs`)
- ...
