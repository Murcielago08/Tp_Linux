# Module 4 : Monitoring


🌞 **Installer Netdata**

- installez-le sur `web.tp6.linux` et `db.tp6.linux`.

`db.tp6.linux`
```
[murci@tp5db ~]$ sudo dnf install epel-release -y
Complete!

[murci@tp5db ~]$ sudo dnf install -y netdata
[...]
Complete!


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

[murci@tp5web ~]$ sudo dnf install -y netdata
[...]
Complete!

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

- l'utilisateur sous lequel tourne le(s) processus Netdata (**même résultat pour la machine web ^^**)

```
[murci@tp5db ~]$ ps -aux | grep netdata.p
netdata     4383  1.0  7.4 488716 73708 ?        SNsl 18:26   0:09 /usr/sbin/netdata -P /run/netdata/netdata.pid -D
netdata     4530  0.0  0.3   4504  3532 ?        SN   18:26   0:00 bash /usr/libexec/netdata/plugins.d/tc-qos-helper.sh 1
netdata     4544  0.7  1.0 134428 10176 ?        SNl  18:26   0:06 /usr/libexec/netdata/plugins.d/apps.plugin 1
root        4546  0.0  4.2 740928 42152 ?        SNl  18:26   0:00 /usr/libexec/netdata/plugins.d/ebpf.plugin 1
netdata     4547  0.1  5.6 773668 55948 ?        SNl  18:26   0:01 /usr/libexec/netdata/plugins.d/go.d.plugin 1
murci       4933  0.0  0.2   6420  2320 pts/0    S+   18:41   0:00 grep --color=auto netdata.p
```

- si Netdata écoute sur des ports (**même résultat pour la machine web ^^**)

```
[murci@tp5db ~]$ sudo ss -lntup | grep netdata
udp   UNCONN 0      0          127.0.0.1:8125       0.0.0.0:*    users:(("netdata",pid=4383,fd=60))
udp   UNCONN 0      0              [::1]:8125          [::]:*    users:(("netdata",pid=4383,fd=41))
tcp   LISTEN 0      4096       127.0.0.1:8125       0.0.0.0:*    users:(("netdata",pid=4383,fd=62))
tcp   LISTEN 0      4096         0.0.0.0:19999      0.0.0.0:*    users:(("netdata",pid=4383,fd=6))
tcp   LISTEN 0      4096           [::1]:8125          [::]:*    users:(("netdata",pid=4383,fd=61))
tcp   LISTEN 0      4096            [::]:19999         [::]:*    users:(("netdata",pid=4383,fd=7))
```

- comment sont consultables les logs de Netdata (**même résultat pour la machine web ^^**)

```
[murci@tp5db ~]$ sudo cat /var/log/netdata/error.log | tail -10
2023-01-17 10:40:27: go.d ERROR: springboot2[local] check failed
2023-01-17 10:40:36: cgroup-name.sh: INFO: cgroup 'init.scope' is called 'init.scope'
/etc/netdata/health_alarm_notify.conf: line 14: unexpected EOF while looking for matching `''
/etc/netdata/health_alarm_notify.conf: line 18: syntax error: unexpected end of file
2023-01-17 10:42:26: alarm-notify.sh: ERROR: Failed to load config file '/etc/netdata/health_alarm_notify.conf'.
/etc/netdata/health_alarm_notify.conf: line 14: unexpected EOF while looking for matching `''
/etc/netdata/health_alarm_notify.conf: line 18: syntax error: unexpected end of file
2023-01-17 11:00:34: alarm-notify.sh: ERROR: Failed to load config file '/etc/netdata/health_alarm_notify.conf'.
2023-01-17 11:00:34: alarm-notify.sh: ERROR: failed to send email notification for: tp5db system.ram.ram_usage is WARNING to 'root' with error code 1 (mkdir: cannot create directory '/usr/share/netdata/.esmtp_queue': Read-only file system
unable to create queue dir /usr/share/netdata/.esmtp_queue).
```

🌞 **Configurer Netdata pour qu'il vous envoie des alertes dans un salon discord** 

**conf pour relier le webhook et netdata: (même chose pour la machine web)**
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

**test alert: (même chose pour la machine web)**
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


🌞 **Vérifier que les alertes fonctionnent**

- en surchargeant volontairement la machine 
- par exemple, effectuez des *stress tests* de RAM et CPU, ou remplissez le disque volontairement

**Pour la machine db et web ^^**
```
[murci@tp5db ~]$ bash -x /usr/libexec/netdata/plugins.d/alarm-notify.sh test
```
