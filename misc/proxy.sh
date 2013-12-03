#!/bin/bash
disable_proxy()
{
    networksetup -setsocksfirewallproxystate Wi-Fi off
    echo "SOCKS proxy disabled."
}

trap disable_proxy INT

networksetup -setsocksfirewallproxystate Wi-Fi on
echo "SOCKS proxy enabled."