# arch-tag: tla buildpackage import utilities
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
import extcmd, tbpconfig, tla

def parsedsc(filename):
    fd = open(filename)
    retval = {}
    for line in fd:
        line = line.strip()
        m = re.search("^([a-zA-Z]+): (.+)$", line)
        if m:
            retval[m.group(1)] = m.group(2)
    return retval

def importorig(dirname, package, version):
    """Side-effect: chdir to wc"""
    wc = tbpconfig.getwcdir()
    os.chdir(wc)

    archive = tla.getarchive()
    version = "%s/%s--head--1.0" % (archive, package)

    isnew = tla.condsetup(version)

    # If it's new, need to create empty dir and then tla_load_dirs
    # into it.  Otherwise, check out latest and tla_load_dirs into that.
    #
    # After doing that, update the config file and commit.
    
