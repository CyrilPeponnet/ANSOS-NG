# remove errors from /sbin/dhclient-script
DHSCRIPT=/sbin/dhclient-script
sed -i 's/mv /cp -p /g'  $DHSCRIPT
sed -i '/rm -f.*${interface}/d' $DHSCRIPT
sed -i '/rm -f \/etc\/localtime/d' $DHSCRIPT
sed -i '/rm -f \/etc\/ntp.conf/d' $DHSCRIPT
sed -i '/rm -f \/etc\/yp.conf/d' $DHSCRIPT

# Hack to make python-sqlalchemy0.7 working on centos. seriously this sucks
mv /usr/lib64/python2.6/site-packages/SQLAlchemy-*-py*-linux-$(uname -m).egg/sqlalchemy /usr/lib64/python2.6/site-packages/