#!/bin/bash

s=`realpath "$0"`
s=`dirname "$s"`

make_hosts_rule(){
    grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' "$1" | while read line; do
        ip=`echo "$line"|grep -oE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'`
        host=`echo "$line"|grep -oE '\S+$'`
        echo "$ip $host"
    done
}


make_dnsmasq_rule(){
    grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' "$1" | while read line; do
        ip=`echo "$line"|grep -oE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'`
        host=`echo "$line"|grep -oE '\S+$'`
        echo "address=/$host/$ip"
    done
}

make_routeros_rule(){
    grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' "$1" | while read line; do
        ip=`echo "$line"|grep -oE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'`
        host=`echo "$line"|grep -oE '\S+$'`
        echo "/ip/dns/static/add name=$host address=$ip"
    done
}

sort_data(){
    now=`date '+%Y-%m-%d %H:%M:%S'`
    echo "# updated on $now" >github.tmp
    sort "$1"|uniq >> github.tmp
    mv -fv github.tmp "$1"
}


cd /tmp
curl -LRk -o g1.txt 'https://gitlab.com/ineo6/hosts/-/raw/master/next-hosts'
curl -LRk -o g2.txt 'https://raw.githubusercontent.com/ittuann/GitHub-IP-hosts/refs/heads/main/hosts'



make_hosts_rule g1.txt >github.hosts
make_hosts_rule g2.txt >>github.hosts
sort_data github.hosts

make_dnsmasq_rule g1.txt >github.conf
make_dnsmasq_rule g2.txt >>github.conf
sort_data github.conf

make_routeros_rule g1.txt >github.rsc
make_routeros_rule g2.txt >>github.rsc
sort_data github.rsc


rm -f g1.txt g2.txt
mv -fv github.conf "$s/"
mv -fv github.hosts "$s/"
mv -fv github.rsc "$s/"

exit
