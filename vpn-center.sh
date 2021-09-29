#!/bin/sh

apt-get update
apt-get -y install wireguard bridge-utils conntrack

################################################################################
## Vagrantfile で付けられなかった IPv6 アドレスを手で付ける
ip addr add dev enp0s8 2001:db8::10/64

################################################################################
## センター拠点の内部ネットワーク側を模擬した bridge
## 100.64.0.10/24 の中に各 VPN クライアントがアクセスしにくるサーバ等が置かれる想定
brctl addbr br-internal
ip link set dev br-internal up
ip addr add dev br-internal 100.64.0.10/24
## 各 VPN クライアントの NAPT 後の足を veth で作って bridge にぶら下げておく
ip link add eth-c00-nsA type veth peer name eth-c00-nsB
ip link add eth-c01-nsA type veth peer name eth-c01-nsB
brctl addif br-internal eth-c00-nsA
brctl addif br-internal eth-c01-nsA
ip link set up eth-c00-nsA
ip link set up eth-c01-nsA
################################################################################


################################################################################
## 各 VPN クライアントの通信を受けて NAPT するための netns を作る
ip netns add c00
ip netns add c01
ip netns exec c00 sysctl -w net.ipv4.ip_forward=1
ip netns exec c01 sysctl -w net.ipv4.ip_forward=1
## NAPT 先の足を 各 netns に送り込んでアドレスをつける
ip link set eth-c00-nsB netns c00
ip link set eth-c01-nsB netns c01
ip netns exec c00 ip addr add dev eth-c00-nsB 100.64.0.20/24
ip netns exec c01 ip addr add dev eth-c01-nsB 100.64.0.30/24
## 各 netns で 100.64.0.0/24 側に出る通信を NAPT 先の足のアドレスで NAPT する
ip netns exec c00 iptables -t nat -A POSTROUTING -o eth-c00-nsB -j MASQUERADE
ip netns exec c01 iptables -t nat -A POSTROUTING -o eth-c01-nsB -j MASQUERADE
################################################################################


################################################################################
## vpn-client00 分の wireguard 受け設定
cat > /etc/wireguard/wg-c00.conf <<EOS
[Interface]
PrivateKey = 4LWrasHirJyUrNG2tvcvjWb1YnVQjdeS7ZqVzpJwe2I=
ListenPort = 50000

[Peer]
PublicKey = T0TU2W33VO10WhAxrGeq+LLrwxUibah/MWJatX2OvTM=
AllowedIPs = 0.0.0.0/0
EOS
ip link add wg-c00 type wireguard
wg setconf wg-c00 /etc/wireguard/wg-c00.conf
ip link set wg-c00 netns c00
ip netns exec c00 ip link set mtu 1420 up dev wg-c00
ip netns exec c00 ip link set up eth-c00-nsB
ip netns exec c00 ip route add default dev wg-c00
################################################################################


################################################################################
## vpn-client01 分の wireguard 受け設定
cat > /etc/wireguard/wg-c01.conf <<EOS
[Interface]
PrivateKey = 4LWrasHirJyUrNG2tvcvjWb1YnVQjdeS7ZqVzpJwe2I=
ListenPort = 50001

[Peer]
PublicKey = wbL4kTCT4t2ooY5St0DZ6/EvATGJ9WV04IUc23YecSA=
AllowedIPs = 0.0.0.0/0
EOS
ip link add wg-c01 type wireguard
wg setconf wg-c01 /etc/wireguard/wg-c01.conf
ip link set wg-c01 netns c01
ip netns exec c01 ip link set mtu 1420 up dev wg-c01
ip netns exec c01 ip link set up eth-c01-nsB
ip netns exec c01 ip route add default dev wg-c01
################################################################################

