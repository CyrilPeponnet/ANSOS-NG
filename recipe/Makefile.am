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

PACKAGE           = @PACKAGE_NAME@
RECIPE            = $(PACKAGE).ks
PRODUCT           = @PRODUCT_NAME@
PRODUCT_SHORT     ?= $(PRODUCT)
PKG_FMT           = iso
FEDORA            = @FEDORA@
RHEL              = @RHEL@
DISTRO            = @DISTRO@
BUILD_TYPE        ?= STABLE
CENTOS            = @CENTOS@
ARCH              = $(shell rpm --eval '%{_arch}')
ANSOS_CREATOR      = $(shell test -e ansos-creator && echo "./ansos-creator" || echo "/usr/sbin/ansos-creator")

FEDORA_MIRROR     = http://mirrors.fedoraproject.org/mirrorlist
CUR_RAWHIDE       = 21
CUR_DEVEL         = 21

CENTOS_MIRROR     = http://mirrorlist.centos.org/
CENTOS_RELEASE    = $(shell rpm --eval '%{centos}' |sed 's/[^0-9]//g')

$(PACKAGE).ks: repos.ks version.ks

repos.ks:
	( \
      if [ -n "$(CENTOS)" ]; then \
        CENTOS_REPO_LINE="repo --name=centos --mirrorlist=$(CENTOS_MIRROR)?release=$(CENTOS_RELEASE)&arch=${ARCH}&repo=os" ;\
        UPDATES_REPO_LINE="repo --name=centos-updates --mirrorlist=$(CENTOS_MIRROR)?release=$(CENTOS_RELEASE)&arch=${ARCH}&repo=updates" ;\
        EPEL_REPO_LINE="repo --name=epel --baseurl=http://dl.fedoraproject.org/pub/epel/$(CENTOS_RELEASE)/${ARCH}/" ;\
        echo "$${CENTOS_REPO_LINE}" > repos.ks ;\
        echo "$${UPDATES_REPO_LINE}" >> repos.ks ;\
        echo "$${EPEL_REPO_LINE}" >> repos.ks ;\
      elif [ -n "$(FEDORA)" ]; then \
            if [ 0$(FEDORA) == 0$(CUR_RAWHIDE) ]; then \
                FEDORA_REPO=rawhide ;\
                FEDORA_REPO_LOC="$(if $(FEDORA_URL),--baseurl=$(FEDORA_URL)/development/rawhide/$(ARCH)/os,--mirrorlist=$(FEDORA_MIRROR)?repo=rawhide&arch=$(ARCH))" ;\
            elif [ 0$(FEDORA) == 0$(CUR_DEVEL) ]; then \
                FEDORA_REPO=f$(FEDORA) ;\
                FEDORA_REPO_LOC="$(if $(FEDORA_URL),--baseurl=$(FEDORA_URL)/development/$(FEDORA)/$(ARCH)/os,--mirrorlist=$(FEDORA_MIRROR)?repo=fedora-$(FEDORA)&arch=$(ARCH))" ;\
                UPDATE_REPO_LINE="repo --name=$${FEDORA_REPO}-updates-testing $(if $(FEDORA_URL),--baseurl=$(FEDORA_URL)/updates/testing/$(FEDORA)/${ARCH},--mirrorlist=$(FEDORA_MIRROR)?repo=updates-testing-f$(FEDORA)&arch=$(ARCH))\n" ;\
            else \
                FEDORA_REPO=f$(FEDORA) ;\
                FEDORA_REPO_LOC="$(if $(FEDORA_URL),--baseurl=$(FEDORA_URL)/releases/$(FEDORA)/Everything/${ARCH}/os,--mirrorlist=$(FEDORA_MIRROR)?repo=fedora-$(FEDORA)&arch=$(ARCH))" ;\
                UPDATE_REPO_LINE="repo --name=$${FEDORA_REPO}-updates $(if $(FEDORA_URL),--baseurl=$(FEDORA_URL)/updates/$(FEDORA)/${ARCH},--mirrorlist=$(FEDORA_MIRROR)?repo=updates-released-f$(FEDORA)&arch=$(ARCH))\n" ;\
            fi ;\
            echo "repo --name=$${FEDORA_REPO} $${FEDORA_REPO_LOC}" > repos.ks ;\
            printf "$${UPDATE_REPO_LINE}" >> repos.ks ;\
      fi ;\
	)

version.ks:
	echo DISTRO $(DISTRO)
	( \
	    echo "PRODUCT='"$(PRODUCT)"'" ;\
	    echo "PRODUCT_SHORT='"$(PRODUCT_SHORT)"'" ;\
	    echo "PACKAGE=$(PACKAGE)" ;\
	    echo "VERSION=$(VERSION)" ;\
	    echo "RELEASE=$(RELEASE)" ;\
	) > $@

$(PACKAGE).$(PKG_FMT) node: version.ks repos.ks
	rm -f $(PACKAGE_NAME).iso
	$(ANSOS_CREATOR) $(RECIPE)
	mv $(PACKAGE_NAME).iso $(PACKAGE_NAME)-$(VERSION)-$(RELEASE).iso
	ln -snf $(PACKAGE_NAME)-$(VERSION)-$(RELEASE).iso $(PACKAGE_NAME).iso

.PHONY: repos.ks version.ks $(PACKAGE).ks
