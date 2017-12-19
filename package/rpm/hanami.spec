# sudo yum -y install rpmdevtools go && rpmdev-setuptree
# rpmbuild -ba ~/rpmbuild/SPECS/hanami.spec

%define _binaries_in_noarch_packages_terminate_build 0

Summary: Resource monitoring and hook for the SAKURA Cloud
Name:    hanami
Version: %{_version}
Release: 1
BuildArch: %{buildarch}
License: Apache-2.0
Group:   SakuraCloud
URL:     https://github.com/sacloud/hanami

Source0:   %{_sourcedir}/hanami_bash_completion
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

%description
Resource monitoring and hook for the SAKURA Cloud

%prep

%build

%install
%{__rm} -rf %{buildroot}
%{__install} -Dp -m0755 %{_builddir}/%{name}  %{buildroot}%{_bindir}/%{name}
%{__mkdir} -p %{buildroot}%{_sysconfdir}/bash_completion.d
%{__install} -m 644 -T %{SOURCE0} %{buildroot}%{_sysconfdir}/bash_completion.d/hanami


%clean
%{__rm} -rf %{buildroot}

%post

%files
%defattr(-,root,root)
%{_bindir}/%{name}
%{_sysconfdir}/bash_completion.d/hanami

%changelog

* Tue Dec 19 2017 <yamamoto.febc@gmail.com> - 0.0.0
- Initial commit
