# Module 4 : Monitoring


🌞 **Installer Netdata**

- installez-le sur `web.tp6.linux` et `db.tp6.linux`.

`db.tp6.linux`
```
[murci@tp5db ~]$ sudo dnf install epel-release -y
Complete!

[murci@tp5db ~]$ curl https://my-netdata.io/kickstart.sh > /tmp/netdata-kickstart.sh && sh /tmp/netdata-kickstart.sh
[...]
Complete!
[...]

[murci@tp5db ~]$ ss -alnp | grep netdata
u_str LISTEN 0      4096                                                   /tmp/netdata-ipc 25363                  * 0

[murci@tp5db ~]$ ss -lant | grep 4096
LISTEN 0      4096         0.0.0.0:19999      0.0.0.0:*

[murci@tp5db ~]$ sudo firewall-cmd --add-port=19999/tcp --permanent
success

[murci@tp5db ~]$ sudo firewall-cmd --reload
success

[murci@tp5db ~]$ sudo systemctl restart netdata
```

`web.tp6.linux`
```
[murci@tp5web ~]$ sudo dnf install epel-release -y
Complete!

[murci@tp5web ~]$ curl https://my-netdata.io/kickstart.sh > /tmp/netdata-kickstart.sh && sh /tmp/netdata-kickstart.sh
[...]
Complete!
[...]

[murci@tp5web ~]$ ss -alnp | grep netdata
u_str LISTEN 0      4096                                                   /tmp/netdata-ipc 25363                  * 0

[murci@tp5web ~]$ ss -lant | grep 4096
LISTEN 0      4096         0.0.0.0:19999      0.0.0.0:*

[murci@tp5web ~]$ sudo firewall-cmd --add-port=19999/tcp --permanent
success

[murci@tp5db ~]$ sudo firewall-cmd --reload
success

[murci@tp5db ~]$ sudo systemctl restart netdata
```

Utilisez votre navigateur pour visiter l'interface web de Netdata `http://<IP_VM>:<PORT_NETDATA>`.

🌞 **Une fois Netdata installé et fonctionnel, déterminer :**

- l'utilisateur sous lequel tourne le(s) processus Netdata

```
[murci@tp5db ~]$ ps -aux | grep netdata.service
murci       4929  0.0  0.2   6424  2132 pts/0    S+   18:41   0:00 grep --color=auto netdata.service
[murci@tp5db ~]$ ps -aux | grep netdata.s
murci       4931  0.0  0.2   6420  2132 pts/0    S+   18:41   0:00 grep --color=auto netdata.s
[murci@tp5db ~]$ ps -aux | grep netdata.p
netdata     4383  1.0  7.4 488716 73708 ?        SNsl 18:26   0:09 /usr/sbin/netdata -P /run/netdata/netdata.pid -D
netdata     4530  0.0  0.3   4504  3532 ?        SN   18:26   0:00 bash /usr/libexec/netdata/plugins.d/tc-qos-helper.sh 1
netdata     4544  0.7  1.0 134428 10176 ?        SNl  18:26   0:06 /usr/libexec/netdata/plugins.d/apps.plugin 1
root        4546  0.0  4.2 740928 42152 ?        SNl  18:26   0:00 /usr/libexec/netdata/plugins.d/ebpf.plugin 1
netdata     4547  0.1  5.6 773668 55948 ?        SNl  18:26   0:01 /usr/libexec/netdata/plugins.d/go.d.plugin 1
murci       4933  0.0  0.2   6420  2320 pts/0    S+   18:41   0:00 grep --color=auto netdata.p
```

- si Netdata écoute sur des ports

```
[murci@tp5db ~]$ sudo ss -lntup | grep netdata
udp   UNCONN 0      0          127.0.0.1:8125       0.0.0.0:*    users:(("netdata",pid=4383,fd=60))
udp   UNCONN 0      0              [::1]:8125          [::]:*    users:(("netdata",pid=4383,fd=41))
tcp   LISTEN 0      4096       127.0.0.1:8125       0.0.0.0:*    users:(("netdata",pid=4383,fd=62))
tcp   LISTEN 0      4096         0.0.0.0:19999      0.0.0.0:*    users:(("netdata",pid=4383,fd=6))
tcp   LISTEN 0      4096           [::1]:8125          [::]:*    users:(("netdata",pid=4383,fd=61))
tcp   LISTEN 0      4096            [::]:19999         [::]:*    users:(("netdata",pid=4383,fd=7))
```

- comment sont consultables les logs de Netdata

```
[murci@tp5db ~]$ sudo cat /var/log/netdata/error.log | tail -10
```

🌞 **Configurer Netdata pour qu'il vous envoie des alertes dans un salon discord** 

**conf pour relier le webhook et netdata:**
```
[murci@tp5db ~]$ sudo cat /etc/netdata/health_alarm_notify.conf
###############################################################################
# sending discord notifications

# note: multiple recipients can be given like this:
#                  "CHANNEL1 CHANNEL2 ..."

# enable/disable sending discord notifications
SEND_DISCORD="YES"

# Create a webhook by following the official documentation -
# https://support.discordapp.com/hc/en-us/articles/228383668-Intro-to-Webhooks
DISCORD_WEBHOOK_URL="[lien de mon webhook]"

if a role's recipients are not configured, a notification will be send to
# this discord channel (empty = do not send a notification for unconfigured
# roles):
DEFAULT_RECIPIENT_DISCORD="alarms"
```

**test alert:**
```
# become user netdata
sudo su -s /bin/bash netdata

# enable debugging info on the console
export NETDATA_ALARM_NOTIFY_DEBUG=1

# send test alarms to sysadmin
/usr/libexec/netdata/plugins.d/alarm-notify.sh test

# send test alarms to any role
/usr/libexec/netdata/plugins.d/alarm-notify.sh test "ROLE"
```

**config pour les différentes alerts:**
```
[murci@tp5db ~]$ sudo cat /etc/netdata/health.d/ram-usage.conf
alarm: ram_usage
    on: system.ram
lookup: average -1m percentage of used
 units: %
 every: 1m
  warn: $this > 50
  crit: $this > 80
  info: The percentage of RAM being used by the system.
```

🌞 **Vérifier que les alertes fonctionnent**

- en surchargeant volontairement la machine 
- par exemple, effectuez des *stress tests* de RAM et CPU, ou remplissez le disque volontairement

```
[murci@tp5db ~]$ stress --vm 1 --vm-bytes 3512M -t 90s -v
```
