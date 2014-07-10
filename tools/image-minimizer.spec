Summary: image-minimizer for stateless optimization
Name: image-minimizer
Version: 1
Release: 0
Source0: %{name}
License: GPL
Group:   Applications/System

%description
Image-minimizer works with specific .ks syntax file to remove part of linux distribution to make it lighter



%build
rm -rf %{buildroot}

%install
mkdir -p %{buildroot}%{_sbindir}/
cp %{SOURCE0} %{buildroot}%{_sbindir}/

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root)
%{_sbindir}/image-minimizer
