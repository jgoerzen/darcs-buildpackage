#!/usr/bin/env python2.3
# arch-tag: primary Python setup script for application

# COPYRIGHT #
# Copyright (C) 2002, 2003 John Goerzen
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
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# END OF COPYRIGHT #

import sys
sys.path = ['.'] + sys.path  # Make sure . is checked first
from distutils.core import setup

setup(name = "tla-buildpackage",
      description = "Integration of Debian build system with tla",
      author = "John Goerzen",
      author_email = "jgoerzen@complete.org",
      url = "http://packages.debian.org/tla-buildpackage",
      packages = ['tbppy'],
      scripts = ['tbp-importdsc', 'tbp-importorig', 'tbp-initarchive',
                 'tla-buildpackage', 'tbp-markdeb'],
      license = "Copyright (C) 2003 John Goerzen" + \
                ", Licensed under the GPL version 2"
)

