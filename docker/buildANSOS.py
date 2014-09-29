#!/usr/bin/python
#
# buildANSOS
#
# Copyright (C) 2014 - Cyril Peponnet cyril@peponnet.fr
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import sys, os, commands, platform
import argparse

PATH = os.path.dirname(os.path.realpath(__file__))
REPO_PATH = os.path.join(PATH, "REPO")
CACHE_PATH = os.path.join(PATH, "CACHE")

### Log messages

def success(msg):
    """
    Print a standardized success message
    @type msg: String
    @param msg: the message to print
    """
    print "\033[32mSUCCESS: %s\033[0m" % msg

def error(msg, exit=True):
    """
    Print a standardized success message
    @type msg: String
    @param msg: the message to print
    @type exit: Boolean
    @param exit: if True, exit after print
    """
    print "\033[31mERROR: %s\033[0m" % msg
    if exit:
        sys.exit(1)

def msg(msg, exit=True):
    """
    Print a standardized neutral message
    @type msg: String
    @param msg: the message to print
    @type exit: Boolean
    @param exit: if True, exit after print
    """
    print "\033[35mMESSAGE: %s\033[0m" % msg

def running(msg, exit=True):
    """
    Print a standardized neutral message
    @type msg: String
    @param msg: the message to print
    @type exit: Boolean
    @param exit: if True, exit after print
    """
    print "\033[94mRUN: %s\033[0m" % msg

def warn(msg):
    """
    Print a standardized warning message
    @type msg: String
    @param msg: the message to print
    """
    print "\033[33mWARNING: %s\033[0m" % msg

### Build functions

def clone_repo(info_repo):
    URL = info_repo[0]
    if len(info_repo) == 1:
        version = "master"
    else:
        version = info_repo[1]

    msg("Cloning %s..." % URL)
    os.system("git clone %s && cd %s && git fetch && git checkout %s" % (URL, URL.split("/")[-1].split(".git")[0], version))

def run(cmd,exit_on_error=True):
    running(cmd)
    if os.system(cmd):
        if exit_on_error:
            error("Wrong return code for %s" % cmd)
        else:
            warn("Wrong return code for %s" % cmd)


### Main function

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-B", "--build",
                        dest="build",
                        help="Build",
                        action="store_true",
                        default=False)
    parser.add_argument("-c", "--clean",
                        dest="clean",
                        help="Clean cache and repo",
                        action="store_true",
                        default=False)
    parser.add_argument("-A", "--archipel-repo",
                        dest="with_archipel",
                        metavar=("GIT_URL","BRANCH/TAG/COMMIT"),
                        nargs=2,
                        help="Archipel sources (default %(default)s)",
                        default=["https://github.com/ArchipelProject/Archipel.git","master"])
    parser.add_argument("--ansos-repo",
                        dest="ansos",
                        metavar=("GIT_URL","BRANCH/TAG/COMMIT"),
                        nargs=2,
                        help="Build with ANSOS from (default %(default)s)",
                        default=["https://github.com/CyrilPeponnet/ANSOS-NG.git","master"])
    parser.add_argument("-o", "--with-openvswitch",
                        dest="with_ovs",
                        metavar="VERSION",
                        nargs="?",
                        help="Build openvswitch with version (default %(const)s)",
                        const="2.1.2")
    parser.add_argument("-k", "--kmod",
                        dest="kmod",
                        help="Build OpenVswitch kernel module (default %(default)s)",
                        action="store_true",
                        default=False)
    parser.add_argument("-e", "--extra-repos",
                        dest="extra_repos",
                        nargs="*",
                        metavar=("REPO_URL1","REPO_URL2"),
                        help="Add extra repos to the recipe")
    parser.add_argument("-p", "--extra-packages",
                        dest="extra_packages",
                        nargs="*",
                        metavar=("pkg1", "pkg2"),
                        help="Add extra packages to install")
    parser.add_argument("-P", "--prefix",
                        dest="prefix",
                        metavar="PATH",
                        help="use prefix as default PATH instead of current dir")

    options = parser.parse_args()

    if not options.build and not options.clean:
        parser.print_help()
        exit(0)

    if options.prefix:
        msg("Use %s as buildir" % options.prefix)
        PATH = options.prefix
        REPO_PATH = os.path.join(PATH, "REPO")
        CACHE_PATH = os.path.join(PATH, "CACHE")

    if not os.path.exists(CACHE_PATH):
        os.makedirs(CACHE_PATH)
    else:
        if options.clean:
            msg("Cleaning %s" % CACHE_PATH)
            run("rm -rf %s/*" % CACHE_PATH)

    if not os.path.exists(REPO_PATH):
        os.makedirs(REPO_PATH)
    else:
        if options.clean:
            msg("Cleaning %s" % REPO_PATH)
            run("rm -rf %s/*" % REPO_PATH)

    if options.build:

        # environment variables
        msg("Setting environment variables")
        os.environ['ANSOS_CACHE_DIR'] = CACHE_PATH
        os.environ['ANSOS_LOCAL_REPO'] = "file://%s/RPMS" % REPO_PATH
        if options.extra_repos:
            os.environ['ANSOS_EXTRA_REPO'] = " ".join(options.extra_repos)
        if options.extra_packages:
            os.environ['ANSOS_EXTRA_PKGS'] = " ".join(options.extra_packages)
        success("Environment variables set")

        os.chdir(CACHE_PATH)
        if options.clean or not os.path.exists(os.path.join(REPO_PATH, "RPMS/repodata")) :
            rpm_topdir = commands.getoutput("rpm --eval %_topdir")
            run("mkdir -p %s/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}" % rpm_topdir)
            run("find %s -iname *.rpm -delete" % rpm_topdir)
            # Building Archipel
            clone_repo(options.with_archipel)
            msg("Create Archipel RPMS")
            run("cd %s/Archipel/ && ./pull.sh" % (CACHE_PATH))
            run("cd %s/Archipel/ArchipelAgent && ./buildAgent -Be %s" % (CACHE_PATH, REPO_PATH))

            # Building OVS if needed
            if options.with_ovs:
                msg("Create OpenVswitch RPMS")
                run("cd %s && wget http://openvswitch.org/releases/openvswitch-%s.tar.gz && tar xzf openvswitch-%s.tar.gz" % (CACHE_PATH, options.with_ovs, options.with_ovs))
                run("cp %s/openvswitch-%s.tar.gz %s/SOURCES" % (CACHE_PATH, options.with_ovs, rpm_topdir, ))
                run("cp %s/openvswitch-%s/rhel/openvswitch-kmod.files %s/SOURCES" % (CACHE_PATH, options.with_ovs, rpm_topdir, ))
                if platform.dist()[0] == "fedora":
                    if not options.kmod:
                        msg("Patching sources file to remove the kmod dependency")
                        run("sed -i 's/openvswitch-kmod//g' %s/openvswitch-%s/rhel/openvswitch-fedora.spec" % (CACHE_PATH ,options.with_ovs))
                    run("cd %s/openvswitch-%s && rpmbuild -bb --without check rhel/openvswitch-fedora.spec" % (CACHE_PATH ,options.with_ovs))
                    if options.kmod:
                        run("cd %s/openvswitch-%s && rpmbuild -bb rhel/openvswitch-kmod-fedora.spec" % (CACHE_PATH ,options.with_ovs))
                else:
                    if not options.kmod:
                        msg("Patching sources file to remove the kmod dependency")
                        run("sed -i 's/openvswitch-kmod//g' %s/openvswitch-%s/rhel/openvswitch.spec" % (CACHE_PATH ,options.with_ovs))
                    run("cd %s/openvswitch-%s && rpmbuild -bb --without check rhel/openvswitch.spec" % (CACHE_PATH ,options.with_ovs))
                    if options.kmod:
                        run("cd %s/openvswitch-%s && rpmbuild -bb rhel/openvswitch-kmod-rhel6.spec" % (CACHE_PATH ,options.with_ovs))

            if not os.path.exists(os.path.join(REPO_PATH, "RPMS/x86_64")):
                os.makedirs(os.path.join(REPO_PATH, "RPMS/x86_64"))
            run("cp %s/RPMS/x86_64/* %s/RPMS/x86_64/" % (rpm_topdir, REPO_PATH), False)
            success("RPMS created and copied to local repo")

            msg("Creating Local RPM Repository")
            run("cd %s/RPMS && createrepo ." % REPO_PATH)
            success("Creating Local RPM Repository")
        else:
            warn("Using already built RPMS, use -c flag for cleaning if needed")

        # Building ANSOS now
        os.environ['RELEASE'] = commands.getoutput("cd %s/Archipel && git rev-parse --short HEAD" % CACHE_PATH)
        msg("Building the live CD")
        clone_repo(options.ansos)
        run("cd %s/ANSOS-NG/recipe/ && aclocal && automake --add-missing && autoconf && ./configure --with-image-minimizer && make archipel-node-image.iso" % CACHE_PATH)
