#
# Makefile	Main Makefile for the net-tools Package
#
# NET-TOOLS	A collection of programs that form the base set of the
#		NET-3 Networking Distribution for the LINUX operating
#		system.
#
# Version:	Makefile 1.33 (1996-05-18)
#
# Author:	Bernd Eckenfels <net-tools@lina.inka.de>
#		Copyright 1995-1996 Bernd Eckebnfels, Germany
#
# URLs:		ftp://ftp.inka.de/pub/comp/Linux/networking/NetTools/ 
#		ftp://ftp.linux.org.uk/pub/linux/Networking/PROGRAMS/NetTools/
#		http://www.inka.de/sites/lina/linux/NetTools/index_en.html
#
# Based on:	Fred N. van Kempen, <waltje@uwalt.nl.mugnet.org>
#		Copyright 1988-1993 MicroWalt Corporation
#
# Modifications:
#		Extensively modified from 01/21/94 onwards by
#		Alan Cox <A.Cox@swansea.ac.uk>
#		Copyright 1993-1994 Swansea University Computer Society
#		
#
#	{1.20}	Bernd Eckenfels:	Even more modifications for the new 
#					package layout
#	{1.21}	Bernd Eckenfels:	Check if config.in is newer than 
#					config.status
#	{1.22}  Bernd Eckenfels:	Include ypdomainname and nisdomainame
#
#	1.3.50-BETA6 private Release
#				
#960125	{1.23}	Bernd Eckenfels:	Peter Tobias' rewrite for 
#					makefile-based installation
#	1.3.50-BETA6a private Release
#
#960201 {1.24}	Bernd Eckenfels:	net-features.h added
#
#960201 1.3.50-BETA6b private Release
#
#960203 1.3.50-BETA6c private Release
#
#960204 1.3.50-BETA6d private Release
#
#960204 {1.25}	Bernd Eckenfels:	DISTRIBUTION added
#
#960205 1.3.50-BETA6e private Release
#
#960206	{1.26}	Bernd Eckenfels:	afrt.o removed (cleaner solution)
#
#960215 1.3.50-BETA6f Release
#
#960216 {1.30}	Bernd Eckenfels:	net-lib support
#960322 {1.31}	Bernd Eckenfels:	moveable netlib, TOPDIR
#960424 {1.32}	Bernd Eckenfels:	included the URLs in the Comment
#
#960514 1.31-alpha release
#
#960518 {1.33}	Bernd Eckenfels:	-I/usr/src/linux/include comment added
#
#	This program is free software; you can redistribute it
#	and/or  modify it under  the terms of  the GNU General
#	Public  License as  published  by  the  Free  Software
#	Foundation;  either  version 2 of the License, or  (at
#	your option) any later version.
#

# set the base of the Installation 
# BASEDIR = /mnt

#
# DON'T CHANGE ANY of the NLS-Support definitions, it's disabled
#
# set default language (DEF_LANG) to en_US.88591 if you don't use NLS
DEF_LANG = en_US.88591

# install national language support for the following languages
# ADD_LANG = fr_FR.88591 de_DE.88591

# path to the net-lib support library. Default: lib
NET-LIB-PATH = lib
NET-LIB-NAME = support

PROGS	= ifconfig hostname arp netstat route rarp 

# Compiler and Linker Options
# You may need to uncomment and edit these if you are using libc5.
COPTS = -O2 -Wall -g # -I/usr/inet6/include
LOPTS = 
RESLIB = # -L/usr/inet6/lib -linet6

# -------- end of user definitions --------

MAINTAINER = Philip.Blundell@pobox.com
RELEASE	   = 980126

.EXPORT_ALL_VARIABLES:

ifeq ("$(NET-LIB-PATH)","lib2")
TOPDIR   = ..
else
TOPDIR  := $(shell if [ "$$PWD" != "" ]; then echo $$PWD; else pwd; fi)
endif

NET-LIB = $(NET-LIB-PATH)/lib$(NET-LIB-NAME).a

CFLAGS	= $(COPTS) -I. -I./include/ -I$(NET-LIB-PATH)
LDFLAGS	= $(LOPTS) -L$(NET-LIB-PATH)

SUBDIRS	= man/ $(NET-LIB-PATH)/

CC	= gcc
LD	= gcc

NLIB	= -l$(NET-LIB-NAME)

USE_NLS := $(shell grep -s 'define NLS 1' config.h)

MDEFINES = COPTS='$(COPTS)' LOPTS='$(LOPTS)' TOPDIR='$(TOPDIR)'

%.o:		%.c config.h version.h net-locale.h net-features.h $<
		$(CC) $(CFLAGS) -c $<

all:		config.h version.h subdirs $(PROGS)

config: 	cleanconfig config.h

install:	all savebin installbin installdata

update: 	all installbin installdata

clean:
		rm -f *.o DEADJOE config.new *~ *.orig lib/*.o
		@for i in $(SUBDIRS); do (cd $$i && make clean) ; done

cleanconfig:
		rm -f config.h

clobber: 	clean
		rm -f $(PROGS) config.h version.h config.status
		@for i in $(SUBDIRS); do (cd $$i && make clobber) ; done


dist: 		clobber
		@echo Creating net-tools-$(RELEASE) in ..
		@tar -cvz -f ../net-tools-$(RELEASE).tar.gz -C .. net-tools


config.h: 	config.in Makefile 
		@echo "Configuring the Linux net-tools (NET-3 Base Utilities)..." ; echo
		@if [ config.status -nt config.in ]; \
			then ./configure.sh <config.status; \
		   else ./configure.sh <config.in; \
		 fi


version.h:	Makefile
		@echo "#define RELEASE \"net-tools $(RELEASE)\"" >version.h


$(NET-LIB):	config.h version.h net-locale.h libdir

net-locale.h:		nlsdir

libdir:
		@$(MAKE) -C $(NET-LIB-PATH) $(MDEFINES)

nlsdir:
		@$(MAKE) -C nls

subdirs:
		@for i in $(SUBDIRS); do $(MAKE) -C $$i $(MDEFINES) ; done

ifconfig:	$(NET-LIB) ifconfig.o
		$(CC) $(LDFLAGS) -o ifconfig ifconfig.o $(NLIB) $(RESLIB)

hostname:	hostname.o
		$(CC) $(LDFLAGS) -o hostname hostname.o

route:		$(NET-LIB) route.o
		$(CC) $(LDFLAGS) -o route route.o $(NLIB) $(RESLIB)

arp:		$(NET-LIB) arp.o
		$(CC) $(LDFLAGS) -o arp arp.o $(NLIB) $(RESLIB)

rarp:		$(NET-LIB) rarp.o
		$(CC) $(LDFLAGS) -o rarp rarp.o $(NLIB)

netstat:	$(NET-LIB) netstat.o statistics.o
		$(CC) $(LDFLAGS) -o netstat netstat.o statistics.o $(NLIB) $(RESLIB)

installbin:
	install -o root -g root -m 0755 arp      ${BASEDIR}/sbin
	install -o root -g root -m 0755 ifconfig ${BASEDIR}/sbin
	install -o root -g root -m 0755 netstat  ${BASEDIR}/bin
	install -o root -g root -m 0755 rarp     ${BASEDIR}/sbin
	install -o root -g root -m 0755 route    ${BASEDIR}/sbin
	install -o root -g root -m 0755 hostname ${BASEDIR}/bin
	ln -fs hostname $(BASEDIR)/bin/dnsdomainname
	ln -fs hostname $(BASEDIR)/bin/ypdomainname
	ln -fs hostname $(BASEDIR)/bin/nisdomainname
	ln -fs hostname $(BASEDIR)/bin/domainname


savebin:
	@for i in ${BASEDIR}/sbin/arp ${BASEDIR}/sbin/ifconfig \
                 ${BASEDIR}/bin/netstat \
		 ${BASEDIR}/sbin/rarp ${BASEDIR}/sbin/route \
		 ${BASEDIR}/bin/hostname ${BASEDIR}/bin/ypdomainname \
                 ${BASEDIR}/bin/dnsdomainname ${BASEDIR}/bin/nisdomainname \
		 ${BASEDIR}/bin/domainname ; do \
		 [ -f $$i ] && cp -f $$i $$i.old ; done ; echo Saved.

installdata:
	install -o root -g root -m 0644 man/${DEF_LANG}/arp.8           ${BASEDIR}/usr/man/man8
	install -o root -g root -m 0644 man/${DEF_LANG}/ifconfig.8      ${BASEDIR}/usr/man/man8
	install -o root -g root -m 0644 man/${DEF_LANG}/netstat.8       ${BASEDIR}/usr/man/man8
	install -o root -g root -m 0644 man/${DEF_LANG}/rarp.8          ${BASEDIR}/usr/man/man8
	install -o root -g root -m 0644 man/${DEF_LANG}/route.8         ${BASEDIR}/usr/man/man8
	install -o root -g root -m 0644 man/${DEF_LANG}/hostname.1      ${BASEDIR}/usr/man/man1
	install -o root -g root -m 0644 man/${DEF_LANG}/dnsdomainname.1 ${BASEDIR}/usr/man/man1
	install -o root -g root -m 0644 man/${DEF_LANG}/ypdomainname.1  ${BASEDIR}/usr/man/man1
	install -o root -g root -m 0644 man/${DEF_LANG}/nisdomainname.1 ${BASEDIR}/usr/man/man1
	install -o root -g root -m 0644 man/${DEF_LANG}/domainname.1    ${BASEDIR}/usr/man/man1
	install -o root -g root -m 0644 man/${DEF_LANG}/ethers.5        ${BASEDIR}/usr/man/man5
#ifneq ($(USE_NLS), "")
#	if [ "${DEF_LANG}" != "en_US.88591" ]; then \
#		install -o root -g root -m 0755 -d ${BASEDIR}/usr/lib/locale/${DEF_LANG} ;\
#		install -o root -g root -m 0644 nls/${DEF_LANG}/nettools.cat ${BASEDIR}/usr/lib/locale/${DEF_LANG} ;\
#	fi
#	for i in $(ADD_LANG); do \
#	install -o root -g root -m 0755 -d ${BASEDIR}/usr/lib/locale/$$i ;\
#	install -o root -g root -m 0644 nls/$$i/nettools.cat ${BASEDIR}/usr/lib/locale/$$i ;\
#	if [ -d man/$$i ]; then \
#	install -o root -g root -m 0755 -d ${BASEDIR}/usr/man/$$i/man8 ;\
#	install -o root -g root -m 0644 man/$$i/arp.8           ${BASEDIR}/usr/man/$$i/man8 ;\
#	install -o root -g root -m 0644 man/$$i/ifconfig.8      ${BASEDIR}/usr/man/$$i/man8 ;\
#	install -o root -g root -m 0644 man/$$i/netstat.8       ${BASEDIR}/usr/man/$$i/man8 ;\
#	install -o root -g root -m 0644 man/$$i/rarp.8          ${BASEDIR}/usr/man/$$i/man8 ;\
#	install -o root -g root -m 0644 man/$$i/route.8         ${BASEDIR}/usr/man/$$i/man8 ;\
#	install -o root -g root -m 0644 man/$$i/hostname.1      ${BASEDIR}/usr/man/$$i/man1 ;\
#	install -o root -g root -m 0644 man/$$i/dnsdomainname.1 ${BASEDIR}/usr/man/$$i/man1 ;\
#	install -o root -g root -m 0644 man/$$i/ypdomainname.1  ${BASEDIR}/usr/man/$$i/man1 ;\
#	install -o root -g root -m 0644 man/$$i/nisdomainname.1 ${BASEDIR}/usr/man/$$i/man1 ;\
#	install -o root -g root -m 0644 man/$$i/domainname.1    ${BASEDIR}/usr/man/$$i/man1 ;\
#	fi ;\
#	done
#endif

# End of Makefile.