# arch-tag: tla buildpackage external command support
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

import popen2, os, re, sys

def handlewaitval(waitval):
    """Returns None if there was no error, or a string describing the problem
    otherwise."""
    if os.WIFEXITED(waitval) and os.WEXITSTATUS(waitval) == 0:
        return None

    errors = []
    if os.WIFEXITED(waitval):
        errors.append("exited normally with error code %d" % \
                      os.WEXITSTATUS(waitval))
    if os.WCOREDUMP(waitval):
        errors.append("core dumped")
    if os.WIFSIGNALED(waitval):
        errors.append("received signal %d" % os.WTERMSIG(waitval))
    return ",".join(errors)

def qrun(command):
    hwv = handlewaitval(os.system(command))
    if hwv:
        raise RuntimeError, "Command %s: %s" % (command, hwv)
    return []

def run(command, debug = 1, capture = 1):
    """Executes command command.  Returns a list of lines of output from that
    command.  Debug may be:

    0 -- completely silent running
    1 -- print commands as they are being run"""

    p =  popen2.Popen3(command)
    if debug:
        print " *", command
    if capture:
        lines = p.fromchild.readlines()
    else:
        lines = []
        for line in p.fromchild:
            sys.stdout.write(line)
    waitval = p.wait()
    waiterrors = handlewaitval(waitval)
    if waiterrors:
        raise RuntimeError, "Command %s: %s" % (command, waiterrors)
    return lines

def extractline(command, lookfor, debug = 1):
    for line in run("dpkg-parsechangelog"):
        r = re.search("^%s: (.+)$" % lookfor, line)
        if r:
            return r.group(1)

    raise RuntimeError, "Could not obtain %s from %s" % (lookfor, command)
