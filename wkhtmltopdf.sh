#!/bin/bash
# Copyright 2020 odooerpcloud.com
OS_NAME=$(lsb_release -cs)
if [[ $OS_NAME == "disco" ]];
then
	echo $OS_NAME
	OS_NAME="bionic"
fi
wk64="https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1."$OS_NAME"_amd64.deb"
wk32="https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1."$OS_NAME"_i386.deb"
sudo rm wkhtmltox_0.12.5-1*.deb
if [[ "`getconf LONG_BIT`" == "32" ]];
then
	sudo wget $wk32
else
	sudo wget $wk64
fi
sudo dpkg -i --force-depends wkhtmltox_0.12.5-1*.deb
sudo ln -s /usr/local/bin/wkhtml* /usr/bin