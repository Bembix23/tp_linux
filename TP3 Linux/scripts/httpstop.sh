#!/bin/bash

firewall-cmd --remove-port=8080/tcp --permanent
firewall-cmd --reload