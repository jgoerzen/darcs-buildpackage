# arch-tag: tla buildpackage utilities for handling configs
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

import re, os, time
import versions, extcmd

class InvalidConfigType(RuntimeError):
    pass

def assertvalidtype(configtype):
    """Makes sure that configtype is valid; if not, raises
    InvalidConfigType."""
    if not configtype in ['debian', 'upstream']:
        raise InvalidConfigType

def makepkgconfigifneeded(configtype, package):
    """Assumes we are in wc dir already."""
    assertvalidtype(configtype)

    if not os.path.exists('configs/%s/%s' % (configtype, package)):
        print "Adding new config dir for this %s package" % configtype
        os.mkdir('configs/%s/%s' % (configtype, package))
        extcmd.run('tla add-tag configs/%s/%s' % (configtype, package))

def makepkgdirifneeded(package):
    """Assumes we are in wc dir already."""
    return 0
    # disabled for now
    #if not os.path.exists('+packages/%s' % package):
    #    print "Adding new package dir for %s" % package
    #    os.mkdir('+packages/%s' % package)
    #    extcmd.run('tla add-tag +packages/%s' % package)

def checkversion(configtype, package, version):
    """Iterates over versions of package present in the directory for
    configtype.  If any of them represent a version the same or newer
    than version, return false; otherwise, return true.

    Assumes already in wc dir."""
    assertvalidtype(configtype)
    for item in os.listdir('configs/%s/%s' % (configtype, package)):
        if item == '{arch}' or item[0] == ',' or item[0] == '.' or \
               item[0:2] == '++' or item == 'latest':
            continue
        if versions.vercmp(item, version) > -1:
            return 0
    return 1

def hasconfig(configtype, package, version):
    """Assumes already in wc dir."""
    assertvalidtype(configtype)
    return os.path.isfile('configs/%s/%s/%s' % (configtype, package,
                                                version))
    

def writeconfig(configtype, package, pkgversion, tlaversion):
    """Writes a config file given the information passed in.  Assumes already
    in wc dir."""
    assertvalidtype(configtype)
    fd = open('configs/%s/%s/%s' % (configtype, package, pkgversion), 'w')
    fd.write("# arch-tag: config for %s package %s version %s (%s)\n" % \
             (configtype, package, pkgversion, str(time.time())))
    if configtype == 'upstream':
        fd.write("./+packages/%s/%s-%s.orig" % (package, package, pkgversion))
    elif configtype == 'debian':
        writeversion = versions.getupstreamver(pkgversion)
        fd.write("./+packages/%s/%s-%s" % (package, package, writeversion))
    fd.write(' %s\n' % tlaversion)
    fd.close()
