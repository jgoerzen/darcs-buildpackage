# arch-tag: tla buildpackage configuration system
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

import os.path, os, sys
import versions

def getwcdir():
    if 'TBP_WC' in os.environ:
        return os.environ['TBP_WC']
    fd = open(os.path.expanduser('~/.tla-buildpackage'))
    return fd.readline().strip()

def pkginit():
    debver = versions.getverfromchangelog()
    upstreamver = versions.getupstreamver(debver)
    package = versions.getpackagefromchangelog()
    wcdir = os.path.abspath(getwcdir())

    
    shouldbe = os.path.realpath(wcdir) + '/+packages/%s/%s-%s' % \
               (package, package, upstreamver)

    if not os.path.realpath(os.getcwd()) == shouldbe:
        print "Current working directory %s" % os.getcwd()
        print "is not part of working copy build area %s" % shouldbe
        print "Exiting."
        sys.exit(50)

    if not os.path.basename(os.getcwd()) == '%s-%s' % (package, upstreamver):
        # I guess this test is redundant now....
        print "Current working directory should be named"
        print "%s-%s but it is %s" % (package, upstreamver,
                                      os.path.basename(os.getcwd()))
        sys.exit(51)
        
    return (debver, upstreamver, package, wcdir)
