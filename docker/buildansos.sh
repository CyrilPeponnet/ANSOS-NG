#!/bin/bash
# ANSOS ISO build script
#
# Copyright (C) 2014 - Cyril Peponnet cyril@peponnet.fr
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA  02110-1301, USA.  A copy of the GNU General Public License is
# also available at http://www.gnu.org/copyleft/gpl.html.

cd /archipel
git clone http://github.com/ArchipelProject/Archipel.git
git clone http://github.com/CyrilPeponnet/ANSOS-NG.git

ANSOS_CACHE_DIR=/ANSOS/ANSOS-cache
ANSOS_LOCAL_REPO=file://${ANSOS_CACHE_DIR}/ANSOS
export ANSOS_CACHE_DIR
export ANSOS_LOCAL_REPO

cd Archipel/ArchipelAgent
if [[ "$1" == "master" ]]; then
  git checkout master
else
  git fetch $1 && git checkout FETCH_HEAD
fi

# Create the rpms for agent
./buildAgent -Be
# Create the repo
cd 'Archipel_RPMS/RPMS' && createrepo .

cd /archipel/ANSOS-NG/
# Create the iso
make distclean
automake --add-missing
autoconf
./configure --with-image-minimizer 
cd recipe
make archipel-node-image.iso
