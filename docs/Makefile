# arch-tag: documentation build system
# Copyright (C) 2003 John Goerzen
# <jgoerzen@complete.org>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

MASTERBASE := tbp
TOPNODE := tbp
BASICDEPS := $(wildcard */*.sgml */*.ent)
DOINDEX := yes
#DOINDEX := no
HTMLARGS := -s local
PSARGS := -s local=printlocal

all: ps
ps: $(MASTERBASE).ps
html: html/index.html

manpages: tla-buildpackage.1 tbp-initarchive.1 tbp-importdsc.1
%.1: man.%.sgml $(wildcard mansgml/*.sgml mansgml/*.ent)
	docbook2man $<

include sgml-common/Makefile.common

realclean: clean
	-rm -rf *.links *.refs tbp-html *.1
