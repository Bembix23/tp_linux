#!/bin/bash
firewall-cmd --add-port=8080/tcp --permanent
firewall-cmd --reload