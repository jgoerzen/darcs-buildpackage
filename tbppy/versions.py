# arch-tag: tla buildpackage version parsing support
# Copyright (C) 2003 John Goerzen
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

import re
import extcmd

def splitver(version):
    """Takes a full version number version and returns a tuple consisting
    of (upstream, debian) versions.  If no Debian version is present,
    the second element of the tuple is None."""
    try:
        i = version.rindex("-")
    except ValueError:
        return (version, None)

    return (version[:i], version[i + 1:])

def getupstreamver(version):
    return splitver(version)[0]

def getdebianver(version):
    return splitver(version)[1]

def getverfromchangelog():
    return extcmd.extractline('dpkg-parsechangelog', 'Version')

def getpackagefromchangelog():
    return extcmd.extractline('dpkg-parsechangelog', 'Source')
