Name:           vpn-isaias
Version:        1.0
Release:        1%{?dist}
Summary:        Gestor de conexiones WireGuard con interfaz en consola (gum)

License:        MIT
URL:            https://github.com/isaiasfl/vpn-isaias
Source0:        vpn-isaias
Source1:        vpn-isaias.desktop

BuildArch:      noarch
Requires:       wireguard-tools, gum

%description
vpn-isaias es una herramienta de consola interactiva para gestionar conexiones VPN WireGuard con 'gum'.

%prep

%build

%install
mkdir -p %{buildroot}/usr/local/bin
mkdir -p %{buildroot}/usr/share/applications
install -m 755 %{SOURCE0} %{buildroot}/usr/local/bin/vpn-isaias
install -m 644 %{SOURCE1} %{buildroot}/usr/share/applications/vpn-isaias.desktop


%files
/usr/local/bin/vpn-isaias
/usr/share/applications/vpn-isaias.desktop

%changelog
* Mon May 20 2024 Isaías FL <isaias@example.com> - 1.0-1
- Versión funcional con icono y permisos correctos
