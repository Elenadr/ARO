#!/bin/sh


######################################################################
######################################################################
# VARIABLES A MODIFICAR
######################################################################
######################################################################

# Interfaces privada y publica del router
PRV_IF=eth1
PUB_IF=eth0

# Direccion IP publica del router NAT
PUB_IP=34.0.0.9

# Rango de direcciones IP privadas
PRV_NET=10.0.0.0/24

######################################################################
######################################################################


# borra todas las tablas de iptables y reinicia los contadores de paquetes
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -Z

# por defecto:
# - descartar todo el trafico entrante que lleva como destino r1
# - descartar todo el trafico de reenvio en r1
# - aceptar todo el trafico de que se genera en r1 y que sale de el
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT



##############
# FORWARD
##############

# reenvia los paquetes desde PRV_IF (red privada) a PUB_IF (Internet)
iptables -A FORWARD -i $PRV_IF -o $PUB_IF -j ACCEPT

# reenvia paquetes de conexiones ya existentes
iptables -A FORWARD -i $PUB_IF -o $PRV_IF -m state --state RELATED,ESTABLISHED -j ACCEPT



##############
# LOCAL
##############

# permitir paquetes dirigidos a r1 que son parte de conexiones existentes
iptables -A INPUT -i $PUB_IF -m state --state RELATED,ESTABLISHED -j ACCEPT

# permitir cualquier entrada a r1 desde la red interna y loopback
iptables -A INPUT -i $PRV_IF -s 0/0 -d 0/0 -j ACCEPT
iptables -A INPUT -i lo -s 0/0 -d 0/0 -j ACCEPT

# permitir la recepcion de icmps desde el exterior
iptables -A INPUT -i $PUB_IF -p ICMP -j ACCEPT



##################
# SNAT en PUB_IF
##################

iptables -A POSTROUTING -t nat -s $PRV_NET -o $PUB_IF -j SNAT --to-source $PUB_IP


##############
# LOG
##############

iptables -A INPUT -j LOG --log-prefix "INPUT --> " --log-level 4
iptables -A FORWARD -j LOG --log-prefix "FORWARD -->" --log-level 4
iptables -A OUTPUT -j LOG --log-prefix "OUTPUT -->" --log-level 4

