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
import extcmd, tbpconfig, tla, versions, configs

def parsedsc(filename):
    fd = open(filename)
    retval = {}
    for line in fd:
        line = line.strip()
        m = re.search("^([a-zA-Z]+): (.+)$", line)
        if m:
            retval[m.group(1)] = m.group(2)
    return retval

def rmrf(dirname):
    print "Removing temporary directory %s..." % dirname
    extcmd.qrun('rm -fr "%s"' % dirname)

def importorigtargz(tarname, package, version):
    """Imports the original source stored in the file named by tarname.

    Side effect: chdir to wc"""
    tarname = os.abspath(tarname)
    wc = os.abspath(tbpconfig.getwcdir())

    tmpdir = os.path.join(wc, ",,tbp-importorigtargz")
    os.mkdir(tmpdir)
    try:
        os.chdir(tmpdir)
        extcmd.qrun('tar -zxSpf "%s"' % tarname)
        if len(os.listdir(tmpdir)) > 1:
            # If it has more than one entry, this directory itself is source,
            # since the tar didn't put things under one dir.  Bad, bad tar.
            srcdir = tmpdir
        else:
            srcdir = os.path.join(tmpdir, os.listdir(tmpdir)[0])
        importorigdir(srcdir, package, version)
    finally:
        rmrf(tmpdir)

def importorigdir(dirname, package, version):
    """Imports the original source stored in directory dirname.

    Side-effect: chdir to wc"""
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
    
    configs.makepkgconfigifneeded('upstream', package)
    if not configs.checkversion('upstream', package, version):
        print "Upstream import: version %s is not newer than all versions in archive" % version
        print "Will not import upstream because of this."
        return

    # OK, we know it's OK....  Now, either create the new dir or check out
    # previous version.

    if os.path.exists(",,tbp-importorigdir"):
        print "Error: ,,tbp-importorigdir already exists; exiting."
        sys.exit(6)

    if isnew:
        os.mkdir(',,tbp-importorigdir')
    else:
        print "Getting latest version for comparison..."
        extcmd.qrun('tla get "%s" ,,tbp-importorigdir' % tlaversion)
        
    try:
        if isnew:
            print "Initializing storage area for upstream..."
            os.chdir(',,tbp-importorigdir')
            extcmd.qrun('tla init-tree "%s"' % tlaversion)
            extcmd.qrun('tla tagging-method explicit')
            extcmd.qrun('tla import')
            os.chdir(wc)
        os.qrun('tla_load_dirs --wc="%s/,,tbp-importorigdir" --summary="Import upstream %s version %s" "%s"' % \
                (wc, package, version, dirname))
        os.chdir('%s/,,tbp-importorigdir' % wc)
        newrev = extcmd.run('tla revisions')[-1]
        newrev = "%s--%s" % (tlaversion, newrev)
        print "Committed %s" % newrev
    finally:
        rmrf("%s/,,tbp-importorigdir" % wc)
        
    # Now add a config for this version.

    os.chdir(wc)
    
    configs.writeconfig('upstream', package, version, newrev)

    extcmd.qrun('tla commit -s "Added configs for upstream %s %s"' % \
                (package, version))
    
