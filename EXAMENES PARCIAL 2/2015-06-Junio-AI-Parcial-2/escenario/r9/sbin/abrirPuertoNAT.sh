#!/bin/sh

# $1 direccion IP privada
# $2 puerto privado
# $3 direccion IP pública
# $4 puerto público
# $5 protocolo

if [ ! $# = 5 ]; then
    echo Número de parámetros incorrecto. Sintaxis:
    echo "     " `basename $0` "<IP-prv> <Pto-prv> <IP-pub> <Pto-pub> <proto>"
    exit 1
fi

######################################################################
######################################################################
# VARIABLES A MODIFICAR
######################################################################
######################################################################

# Interfaces privada y publica del router
PRV_IF=eth1
PUB_IF=eth0

######################################################################
######################################################################


PROT="`echo $5 | tr [:upper:] [:lower:]`"


echo -e "Abriendo un puerto..."
echo -e "Direccion IP privada:\t$1"
echo -e "Puerto privado:\t\t$2"
echo -e "Direccion IP pública:\t$3"
echo -e "Puerto público:\t\t$4"
echo -e "Protocolo:\t\t$PROT"

# abrir el puerto para que en el router se acepte el tráfico
# entrante nuevo dirigido a la direccion $3:$4
iptables -A PREROUTING -t nat -s 0/0 -d $3/32 -i $PUB_IF -p $PROT --dport $4  -j DNAT --to $1:$2 

if [ $PROT = "tcp" ]; then 
    iptables -A FORWARD -p tcp -s 0/0 -d $1/32 --dport $2 --syn -j ACCEPT 

elif [ $PROT = "udp" ]; then
    iptables -A FORWARD -p udp -s 0/0 -d $1/32 --dport $2  -j ACCEPT 

fi



