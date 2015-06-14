# 
# Do NOT Edit the Auto-generated Part!
# Generated by: spectacle version 0.27
# 

Name:       harbour-textractor

# >> macros
%define __provides_exclude_from ^%{_datadir}/.*$
%define __requires_exclude ^libtesseract|libjpeg|libc\\.so\\.6\\(GLIBC_2\\.11\\)|liblept.*$
# << macros

%{!?qtc_qmake:%define qtc_qmake %qmake}
%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%{?qtc_builddir:%define _builddir %qtc_builddir}
Summary:    Optical character recognition application.
Version:    0.3
Release:    0
Group:      Qt/Qt
License:    MIT
URL:        http://skvark.github.io/Textractor/
Source0:    %{name}-%{version}.tar.bz2
Source100:  harbour-textractor.yaml
Requires:   sailfishsilica-qt5 >= 0.10.9
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.2
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  desktop-file-utils

%description
Textractor is and OCR application made with Tesseract OCR and Leptonica.


%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
# << build pre

%qtc_qmake5  \
    VERSION='%{version}-%{release}'

%qtc_make %{?_smp_mflags}

# >> build post
# << build post

%install
rm -rf %{buildroot}
# >> install pre
# << install pre
%qmake5_install

# >> install post
mkdir %{buildroot}%{_datadir}/%{name}/lib/
cp -f /usr/lib/libtesseract.so.3 %{buildroot}%{_datadir}/%{name}/lib/
cp -f /usr/lib/liblept.so.4 %{buildroot}%{_datadir}/%{name}/lib/
cp -f /usr/lib/libjpeg.so.62 %{buildroot}%{_datadir}/%{name}/lib/
# << install post

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
# >> files
%defattr(-,root,root,-)
%defattr(0644,root,root,0755)
%attr(0755,-,-) %{_bindir}/%{name}
# << files
%{_bindir}
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/86x86/apps/%{name}.png
%{_datadir}/harbour-textractor/lib/*