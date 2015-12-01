check_disk
=================


* Checks for all linux mounted partitions
* Based on `df`
* Performance data shows percentage used and MB total/used


 
 # Requirements
 * Bash v4
 * df
 
# Example
    $ ./check_disk.sh -w <warning> -c <critical>

# Output
    $ ./check_disk.sh -w 85 -c 90
    Disk Usage OK -  /:37% Used  /boot:18% Used  |   /_pct=37%;80;90;0;100; /_used=33882MiB;;;;; /_total=98916MiB;;;;;  /boot_pct=18%;80;90;0;100; /boot_used=38MiB;;;;; /boot_total=236MiB;;;;;
 

