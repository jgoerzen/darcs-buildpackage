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

import re, sys, os
import extcmd, tbpconfig, tla, versions

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
    print " *** Import upstream package %s version %s from directory %s" % (package, version, dirname)
    dirname = os.abspath(dirname)
    wc = os.abspath(tbpconfig.getwcdir())
    os.chdir(wc)

    archive = tla.getarchive()
    tlaversion = "%s/%s--head--1.0" % (archive, package)
    print "tla version will be %s" % tlaversion

    isnew = tla.condsetup(tlaversion)

    # If it's new, need to create empty dir and then tla_load_dirs
    # into it.  Otherwise, check out latest and tla_load_dirs into that.
    #
    # After doing that, update the config file and commit.
    
    if not os.path.exists('configs/upstream/%s' % package):
        print "Adding new config dir for this upstream"
        os.mkdir('configs/upstream/%s' % package)
        extcmd.run('tla add configs/upstream/%s' % package)

    for item in os.listdir('configs/upstream/%s' % package):
        if item == '{arch}' or item[0] == ',' or item[0] == '.' or \
           item[0:2] == '++' or item == 'latest':
            continue
        if versions.vercmp(item, version) > -1:
            print "Upstream import: found version %s, not less than %s" % (item, version)
            print "Will not import upstream because of this."
            return


    #if not exists('configs/upstream/%s/latest' % package):
    #    # Create the latest config
    #    fd = open('configs/upstream/%s/latest' % package, 'w')
    #    fd.write("# arch-tag: config file for upstream %s, %s\n" % \
    #             (package, str(time.time())))
    #    fd.write("./packages
    
    
    # OK, we know it's OK....  Now, either create the new dir or check out
    # previous version.

    if os.path.exists(",,tbp-tmp"):
        print "Error: ,,tbp-tmp already exists; exiting."
        sys.exit(6)

    if isnew:
        os.mkdir(',,tbp-tmp')
    else:
        print "Getting latest version for comparison..."
        extcmd.qrun('tla get "%s" ,,tbp-tmp' % tlaversion)
        
    try:
        if isnew:
            print "Initializing storage area for upstream..."
            os.chdir(',,tbp-tmp')
            extcmd.qrun('tla init-tree "%s"' % tlaversion)
            extcmd.qrun('tla tagging-method explicit')
            extcmd.qrun('tla import')
            os.chdir(wc)
        os.qrun('tla_load_dirs --wc="%s/,,tbp-tmp" --summary="Import upstream %s version %s" "%s"' % \
                (wc, package, version, dirname))
        os.chdir('%s/,,tbp-tmp' % wc)
        newrev = extcmd.run('tla revisions')[-1]
        newrev = "%s--%s" % (tlaversion, newrev)
        print "Committed %s" % newrev
    finally:
        print "Removing temporary directory..."
        extcmd.qrun('rm -fr "%s/,,tbp-tmp"' % wc)
        
    # Now add a config for this version.

    os.chdir(wc)
    
    fd = os.path.open('configs/upstream/%s/%s' % (package, version), 'w')
    fd.write("# arch-tag: config for upstream %s version %s (%s)\n" % \
             (package, version, str(time.time())))
    fd.write("./packages/%s/%s-%s.orig" % (package, package, version))
    fd.write(' %s\n' % newrev)
    fd.close()

    extcmd.qrun('tla commit -s "Added configs for upstream %s %s"' % \
                (package, version))
    
