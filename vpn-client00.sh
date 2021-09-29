#!/bin/sh

apt-get update
apt-get -y install wireguard bridge-utils conntrack

################################################################################
## Vagrantfile で付けられなかった IPv6 アドレスを手で付ける
ip addr add dev enp0s8 2001:db8::20/64


################################################################################
## 各クライアントのおうちの LAN セグメント想定 (vpn-client00 と vpn-client01 で意図的に同じアドレスを使う)
brctl addbr br-client00
ip link set dev br-client00 up
ip addr add dev br-client00 192.168.1.10/24
sysctl -w net.ipv4.ip_forward=1
################################################################################


################################################################################
## センタ拠点向けに繋ぎに行く wireguard 設定
cat > /etc/wireguard/wg0.conf <<EOS
[Interface]
PrivateKey = UEDC4UmabmflqAhnlP8IcqClGYgiL5MIUmaNg0lKYEQ=

[Peer]
PublicKey = mzOD4tzIVAU9ty38eSawlDiWKOG2chqdfyus9krIcAs=
#EndPoint = 203.0.113.10:50000
EndPoint = [2001:db8::10]:50000
AllowedIPs = 100.64.0.0/16
EOS
ip link add wg0 type wireguard
wg setconf wg0 /etc/wireguard/wg0.conf
ip link set mtu 1420 up dev wg0
ip r add dev wg0 100.64.0.0/16
################################################################################
