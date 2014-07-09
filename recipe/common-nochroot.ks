%include version.ks

# store image version info in the ISO and rootfs
cat > $LIVE_ROOT/isolinux/version <<EOF
PRODUCT='$PRODUCT'
PRODUCT_SHORT='${PRODUCT_SHORT}'
PRODUCT_CODE=$PRODUCT_CODE
RECIPE_SHA256=$RECIPE_SHA256
RECIPE_RPM=$RECIPE_RPM
PACKAGE=$PACKAGE
VERSION=$VERSION
RELEASE=$RELEASE
EOF
cp $LIVE_ROOT/isolinux/version $INSTALL_ROOT/etc/default/

# overwrite user visible banners with the image versioning info
# system-release in rootfs get's updated, but now it's out of sync with initrd
# The only bit which is missing in the initrd system-release file is VERSION
# /(which is not shown in ply anyway)
# The initrd can not be regeneated in a non-chroot env (here)
cat > $INSTALL_ROOT/etc/$PACKAGE-release <<EOF
$PRODUCT release $VERSION ($RELEASE)
EOF
ln -snf $PACKAGE-release $INSTALL_ROOT/etc/redhat-release
ln -snf $PACKAGE-release $INSTALL_ROOT/etc/system-release
cp $INSTALL_ROOT/etc/$PACKAGE-release $INSTALL_ROOT/etc/issue
echo "Kernel \r on an \m (\l)" >> $INSTALL_ROOT/etc/issue
cp $INSTALL_ROOT/etc/issue $INSTALL_ROOT/etc/issue.net