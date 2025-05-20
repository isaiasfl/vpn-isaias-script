# 🛡️ vpn-isaias

**vpn-isaias** es una herramienta de consola moderna e interactiva para gestionar conexiones VPN WireGuard usando una interfaz TUI basada en [gum](https://github.com/charmbracelet/gum).  
Funciona en Fedora, Debian/Ubuntu y Arch Linux, y permite seleccionar, conectar y desconectar múltiples perfiles VPN desde el terminal.

---

## 📦 Requisitos

Debes tener instalado:

- `wireguard-tools`
- `gum` (interfaz TUI interactiva)
- Herramientas de compilación de paquetes RPM (opcional para Fedora)

---

## 📥 Instalación por distribución

### 🐧 Fedora

```bash
sudo dnf install wireguard-tools gum rpm-build rpmdevtools
```

### 🐧 Debian / Ubuntu

```bash
sudo apt update
sudo apt install wireguard-tools gum build-essential devscripts dh-make
```

### 🐧 Arch Linux

```bash
sudo pacman -S wireguard-tools gum base-devel
```

---

## 🔧 Clonar el repositorio

```bash
git clone https://github.com/isaiasfl/vpn-isaias.git
cd vpn-isaias
```

---

## 🧪 Probar el script directamente

```bash
chmod +x vpn-isaias.sh
sudo ./vpn-isaias.sh
```

---

## 🛠️ Construir e instalar el paquete RPM (solo Fedora)

```bash
rpmdev-setuptree  # Solo la primera vez
cp vpn-isaias.sh ~/rpmbuild/SOURCES/vpn-isaias
cp vpn-isaias.desktop ~/rpmbuild/SOURCES/
cp vpn-isaias.spec ~/rpmbuild/SPECS/
rpmbuild -ba ~/rpmbuild/SPECS/vpn-isaias.spec
sudo dnf install ~/rpmbuild/RPMS/noarch/vpn-isaias-1.0-1.noarch.rpm
```

---

## 🖥️ Lanzar desde el menú

Tras instalar el `.rpm`, puedes buscar "VPN Isaías" en el menú de aplicaciones. El lanzador abre el script en terminal con interfaz TUI.

---

## 📁 Estructura del proyecto

```
vpn-isaias/
├── vpn-isaias.sh              # Script principal funcional
├── vpn-isaias.desktop         # Entrada de aplicación gráfica
├── vpn-isaias.spec            # Especificación para crear el .rpm
└── README.md                  # Este documento
```

---

## ✍️ Autor

📌 Isaías FL  
🔗 [github.com/isaiasfl](https://github.com/isaiasfl)

---

## 🧾 Licencia

MIT License
