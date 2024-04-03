# TP 1.5 : Proposer une image renforcée

## Sommaire

- [TP 1.5 : Proposer une image renforcée](#tp-15--proposer-une-image-renforcée)
  - [Sommaire](#sommaire)
  - [1. Guides CIS](#1-guides-cis)
  - [2. Conf SSH](#2-conf-ssh)
  - [3. DoT](#3-dot)

## 1. Guides CIS

CIS est une boîte qui, notamment, édite des **guides de configuration assez réputés** pour sécuriser les installations des OS courants. Des OS Linux, mais pas que.

🌞 **Suivre un guide CIS**

  - 2.1.1 Ensure time synchronization is in use
```bash
[vagrant@rocky9 ~]$ rpm -q chrony
chrony-4.3-1.el9.x86_64
```
  - 2.1.2 Ensure chrony is configured
```bash
[vagrant@rocky9 ~]$grep -E "^(server|pool)" /etc/chrony.conf
pool 2.rocky.pool.ntp.org iburst
```
```bash
[vagrant@rocky9 ~]$ grep ^OPTIONS /etc/sysconfig/chronyd
OPTIONS="-u chrony"
```
  - 3.1.1 Ensure IPv6 status is identified
```bash
[vagrant@rocky9 ~]$  grep -Pqs '^\h*0\b' /sys/module/ipv6/parameters/disable && echo -e "\n -
IPv6 is enabled\n" || echo -e "\n - IPv6 is not enabled\n"

 -
IPv6 is enabled
```
  - 3.1.2 Ensure wireless interfaces are disabled
```bash
[vagrant@rocky9 ~]$ ./script.sh

- Audit Result:
 ** PASS **

 - System has no wireless NICs installed
 ```
   - 3.1.3 Ensure TIPC is disabled
```bash
[vagrant@rocky9 ~]$ ./script.sh
- Audit Result:
 ** PASS **

 - Module "tipc" doesn't exist on the
system
```
  - 3.2.1 Ensure IP forwarding is disabled
```bash
- Audit Result:
 ** FAIL **
 - Reason(s) for audit
failure:

 - "net.ipv4.ip_forward = 0" is not set
in a kernel parameter configuration file
 - "net.ipv6.conf.all.forwarding = 0" is not set
in a kernel parameter configuration file


- Correctly set:

 - "net.ipv4.ip_forward" is set to
"0" in the running configuration
 - "net.ipv4.ip_forward" is not set incorectly in
a kernel parameter configuration file
 - "net.ipv6.conf.all.forwarding" is set to
"0" in the running configuration
 - "net.ipv6.conf.all.forwarding" is not set incorectly in
a kernel parameter configuration file
```

Remediation:

```bash
[vagrant@rocky9 ~]$ printf "
net.ipv4.ip_forward = 0
" >> /etc/sysctl.d/60-netipv4_sysctl.conf
Run the following command to set the active kerne
```

```bash
[vagrant@rocky9 ~]$ {
 sysctl -w net.ipv4.ip_forward=0
 sysctl -w net.ipv4.route.flush=1
}

net.ipv4.ip_forward = 0
net.ipv4.route.flush = 1
```

(pareil pour ipv6)



  - les sections 3.1 3.2 et 3.3
  - toute la section 5.2 Configure SSH Server
  - au moins 10 points dans la section 6.1 System File Permissions
  - au moins 10 points ailleurs sur un truc que vous trouvez utile

## 2. Conf SSH

![SSH](./img/ssh.jpg)

🌞 **Chiffrement fort côté serveur**

- *vous pouvez faire toutes ces confs à la main, avant de repackager*
- trouver une ressource de confiance (je veux le lien en compte-rendu) qui indique quelle configuration vous devriez mettre en place
- configurer le serveur SSH pour qu'il utilise des paramètres forts en terme de chiffrement (je veux le fichier de conf dans le compte-rendu)
  - des lignes de conf à ajouter dans le fichier de conf
  - regénérer des clés pour le serveur ?
  - regénérer les paramètres Diffie-Hellman ? (se renseigner sur Diffie-Hellman ?)

🌞 **Clés de chiffrement fortes pour le client**

- *vous déposerez votre clé avec `cloud-init` dans la VM lors de son premier boot*
- trouver une ressource de confiance (je veux le lien en compte-rendu) qui indique quel chiffrement vous devriez utiliser
- générez-vous une paire de clés qui utilise un chiffrement fort et une passphrase
- ne soyez pas non plus absurdes dans le choix du chiffrement quand je dis "fort" (genre pas de RSA avec une clé de taile 98789080932083209 bytes, il faut que ça reste réaliste et utile)

🌞 **Connectez-vous en SSH à votre VM avec cette paire de clés**

- prouvez en ajoutant `-vvvv` sur la commande `ssh` de connexion que vous utilisez bien cette clé là

## 3. DoT

Ca commence à faire quelques années maintenant que plusieurs acteurs poussent pour qu'on fasse du DNS chiffré, et qu'on arrête d'envoyer des requêtes DNS en clair dans tous les sens.

En effet, par défaut dans la plupart des utilisations, les requêtes DNS émises par un client sont envoyées en clair. Ainsi n'importe qui peut observer quelles requêtes DNS sont effectuées par un client donné, et éventuellement jouer avec.

**Le DoT est une techno qui permet de se protéger de ça : DoT pour DNS over TLS. On fait nos requêtes DNS dans des tunnels chiffrés avec le protocole TLS.**

🌞 **Configurer la machine pour qu'elle fasse du DoT**

- *vous pouvez faire toutes ces confs à la main, avant de repackager*
- installez `systemd-resolved` sur la machine pour ça
- activez aussi DNSSEC tant qu'on y est
- [référez-vous à cette doc qui est cool par exemple](https://wiki.archlinux.org/title/systemd-resolved)
- utilisez le serveur public de CloudFlare : 1.1.1.1 (il supporte le DoT)

> *Donc normalement : install du paquet, modif du fichier `/etc/systemd/resolved.conf` pour activer le DoT, activer DNSSEC et utiliser `1.1.1.1`, puis une commande pour modifier le contenu de `/etc/resolv.conf`, et enfin, redémarrer le service `systemd-resoved`.*

🌞 **Vérifiez que les requêtes DNS effectuées par la machine...**

- ont une réponse qui provient du serveur que vous avez conf (normalement c'est `127.0.0.1` avec `systemd-networkd` qui tourne)
  - quand on fait un `dig ynov.com` on voit en bas quel serveur a répondu
- mais qu'en réalité, la requête a été forward vers 1.1.1.1 avec du TLS
  - vous pouvez (*devriez*) utiliser **Wireshark** pour vérifier ça : voir que la requête DNS ne circule pas en clair

![Spying](./img/spy.png)
