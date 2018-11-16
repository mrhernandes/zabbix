#!/usr/bin/env python
# -*- coding: utf-8 -*-
#Script para criar host via api.
#Criado por Hernandes Martins
#Atualizado em 16/11/2018
#Contato: hernandss@gmail.com

from zabbix_api import ZabbixAPI
zapi = ZabbixAPI(server="http://192.168.56.102/zabbix")
zapi.login("Admin", "zabbix")

zapi.host.create({"host": "ZabbixAPI", 
                 "interfaces": [ {"type": "1",
                 "main": "1",
                 "useip": "1",
                 "ip": "19.168.100.5",
                 "dns": "",
                 "port": "10051"}],
                 "groups": [{ "groupid": "2"}],
                 "templates": [{ "templateid": "10001"}]})