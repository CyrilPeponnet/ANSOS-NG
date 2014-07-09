dnl
dnl Licensed to the Apache Software Foundation (ASF) under one or more
dnl contributor license agreements.  See the NOTICE file distributed with
dnl this work for additional information regarding copyright ownership.
dnl The ASF licenses this file to You under the Apache License, Version 2.0
dnl (the "License"); you may not use this file except in compliance with
dnl the License.  You may obtain a copy of the License at
dnl
dnl     http://www.apache.org/licenses/LICENSE-2.0
dnl
dnl Unless required by applicable law or agreed to in writing, software
dnl distributed under the License is distributed on an "AS IS" BASIS,
dnl WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
dnl See the License for the specific language governing permissions and
dnl limitations under the License.
dnl

AC_PREREQ(2.60)

define([VERSION_MAJOR], [1])
define([VERSION_MINOR], [0])
define([VERSION_FIX], [0])
define([VERSION_NUMBER], VERSION_MAJOR[.]VERSION_MINOR[.]VERSION_FIX)
define([VERSION_SUFFIX], [_master])

AC_INIT([archipel-ansos], VERSION_NUMBER[]VERSION_SUFFIX, [primalmotion@archipelproject.org])
PACKAGE_RPM_VERSION="VERSION_NUMBER"
PACKAGE_RPM_RELEASE="0.0.$(echo VERSION_SUFFIX | sed 's/^_//')"
AC_SUBST([PACKAGE_RPM_VERSION])
AC_SUBST([PACKAGE_RPM_RELEASE])

AM_INIT_AUTOMAKE([-Wall -Werror foreign -Wno-portability tar-pax])

AC_ARG_VAR([RPMBUILD], [path to rpmbuild utility])
AC_CHECK_PROGS([RPMBUILD], [rpmbuild])

AC_SUBST([FEDORA],[[`rpm --eval '%{fedora}'|sed 's/[^0-9]//g'`]])
AC_SUBST([RHEL], [[`rpm --eval '%{rhel}'|sed 's/[^0-9]//g'`]])
AC_SUBST([CENTOS], [[`rpm --eval '%{centos}'|sed 's/[^0-9]//g'`]])
AC_SUBST([DISTRO])
AC_SUBST([PACKAGE_NAME])
AC_SUBST([PRODUCT_NAME])

if test "$FEDORA"; then
    DISTRO=fc$FEDORA
fi
if test "$RHEL"; then
    DISTRO=rhevh$RHEL
fi
if test "$CENTOS"; then
    DISTRO=centos$CENTOS
fi

AM_CONDITIONAL(TARGET_FEDORA, test x"$FEDORA" != x)
AM_CONDITIONAL(TARGET_RHEL, test x"$RHEL" != x && test x"$CENTOS" == x)
AM_CONDITIONAL(TARGET_CENTOS, test x"$CENTOS" != x)
AM_CONDITIONAL(TARGET_EL6, test x"$RHEL" != x || test x"$CENTOS" != x)

AC_ARG_WITH([image-minimizer], [AC_HELP_STRING([--with-image-minimizer],
            [enable aggresive reduction of the image size])],
            [IMAGE_MINIMIZER="%include image-minimizer.ks"],
            [IMAGE_MINIMIZER=""])
AC_SUBST([IMAGE_MINIMIZER])


PACKAGE_NAME=archipel-node-image
PRODUCT_NAME=Archipel\ Node\ Hypervisor\ $DISTRO
MAIN_KS=archipel-node-image.ks

AM_PATH_PYTHON

AC_CONFIG_FILES([
                Makefile
                $MAIN_KS
                image-minimizer.ks])
AC_OUTPUT
