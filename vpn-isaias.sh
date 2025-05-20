#!/bin/bash

# ┌──────────────────────────────────────────────┐
# │ VPN-ISAÍAS – Gestor de VPNs WireGuard       │
# │ Autor: Isaías FL                            │
# │ Repo: https://github.com/isaiasfl/vpn-isaias│
# └──────────────────────────────────────────────┘

clear
LOG_FILE="/var/log/vpn-isaias.log"

if [ "$EUID" -ne 0 ]; then
  echo "🔐 Se requieren permisos de administrador. Reiniciando con sudo..."
  exec sudo "$0" "$@"
fi

install_gum() {
  if ! command -v gum &>/dev/null; then
    echo "🌱 Instalando GUM..."
    source /etc/os-release
    case "$ID" in
      fedora) dnf install -y gum ;;
      ubuntu|debian) apt update && apt install -y gum ;;
      arch) pacman -Sy --noconfirm gum ;;
      *) echo "⚠️ Distribución no soportada automáticamente. Instala 'gum' manualmente."; exit 1 ;;
    esac
  fi
}

install_gum

listar_vpns() {
  find /etc/wireguard -maxdepth 1 -type f -name "*.conf" -exec basename {} .conf \;
}

mostrar_info_vpn() {
  local iface="$1"
  local pub_ip=$(curl -s ifconfig.me)
  local info=$(wg show "$iface")
  local address=$(grep Address /etc/wireguard/"$iface".conf | awk '{print $3}')
  local peer=$(echo "$info" | grep 'peer:' | awk '{print $2}')
  local endpoint=$(echo "$info" | grep 'endpoint:' | awk '{print $2}')
  local latest_handshake=$(echo "$info" | grep 'latest handshake:' | cut -d':' -f2-)
  local transfer_rx=$(echo "$info" | grep 'transfer:' | awk '{print $2,$3}')
  local transfer_tx=$(echo "$info" | grep 'transfer:' | awk '{print $5,$6}')

  gum join --vertical \
    "$(gum style --foreground 36 "🔐  VPN Conectada: $iface")" \
    "$(gum style --foreground 36 "🌍  IP Pública: $pub_ip")" \
    "$(gum style --foreground 36 "📡  IP Interna: $address")" \
    "$(gum style --foreground 36 "🍌  Peer: $peer")" \
    "$(gum style --foreground 36 "🍫  Endpoint: $endpoint")" \
    "$(gum style --foreground 36 "⏰  Último Handshake: $latest_handshake")" \
    "$(gum style --foreground 36 "⬇️  RX: $transfer_rx    ⬆️  TX: $transfer_tx")"
}

mostrar_info_vpn_activa() {
  local active=$(wg show interfaces | head -n 1)
  if [ -z "$active" ]; then
    gum style --foreground 11 --border normal "⚠️ No hay ninguna VPN activa."
  else
    mostrar_info_vpn "$active"
    gum input --placeholder "Pulsa ENTER para continuar..." > /dev/null
  fi
}

conectar_vpn() {
  clear
  local vpns=($(listar_vpns))
  if [ ${#vpns[@]} -eq 0 ]; then
    gum style --foreground 9 "❌ No se han encontrado configuraciones VPN en /etc/wireguard/"
    return
  fi

  vpns+=("❌ Salir")
  local seleccion=$(printf "%s\n" "${vpns[@]}" | gum choose --header="🌍 Selecciona una VPN para conectarte:")

  if [[ "$seleccion" == "❌ Salir" || -z "$seleccion" ]]; then
    return
  fi

  local config="/etc/wireguard/${seleccion}.conf"
  if [ ! -f "$config" ]; then
    gum style --foreground 9 "❌ Archivo de configuración no encontrado: $config"
    return
  fi

  local active=$(wg show interfaces | head -n 1)
  if [ "$active" == "$seleccion" ]; then
    mostrar_info_vpn "$seleccion"
    gum input --placeholder "Pulsa ENTER para continuar..." > /dev/null
    return
  elif [ -n "$active" ]; then
    if gum confirm "🔄 Estás conectado a '$active'. ¿Deseas desconectarte y conectar a '$seleccion'?" ; then
      wg-quick down "$active"
      echo "$(date) 🔌 Desconectado de $active" >> "$LOG_FILE"
    else
      gum style --foreground 10 "🚫 Manteniendo conexión actual."
      return
    fi
  fi

  gum style --border normal --padding "1" --margin "1" --foreground 35 \
    "📄 Conexión seleccionada: $seleccion" \
    "$(grep -E 'Address|Endpoint|DNS|AllowedIPs' "$config")"

  if gum confirm "🔌 ¿Deseas conectarte a '$seleccion'?" ; then
    if wg-quick up "$seleccion" &>/dev/null; then
      sleep 1
      echo "$(date) ✅ Conectado a $seleccion" >> "$LOG_FILE"
      clear
      mostrar_info_vpn "$seleccion"
      gum input --placeholder "Pulsa ENTER para continuar..." > /dev/null
    else
      gum style --foreground 9 "❌ Error al conectar a '$seleccion'"
      echo "$(date) ❌ Error al conectar a $seleccion" >> "$LOG_FILE"
    fi
  fi
}

mostrar_logs() {
  if [ ! -f "$LOG_FILE" ]; then
    gum style --border normal --padding "1" --foreground 244 "📜 No hay registros todavía."
  else
    gum style --border normal --padding "1" --foreground 244 "$(cat "$LOG_FILE")"
  fi
  gum input --placeholder "Pulsa ENTER para volver al menú..." > /dev/null
}

desconectar_vpn() {
  local active=$(wg show interfaces | head -n 1)
  if [ -n "$active" ]; then
    if gum confirm "🔌 ¿Seguro que deseas desconectarte de '$active'?" ; then
      wg-quick down "$active"
      echo "$(date) 🔌 Desconectado de $active" >> "$LOG_FILE"
      gum style --foreground 1 "🔻 VPN '$active' desconectada."
      sleep 1
    fi
  fi
}

while true; do
  clear
  opciones=(
    "🔌 Conectar a una VPN"
    "📊 Ver información de la VPN activa"
    "🧾 Ver log de conexiones"
  )
  if wg show interfaces | grep -q .; then
    opciones+=("🔻 Desconectar VPN activa")
  fi
  opciones+=("❌ Salir")

  opcion=$(printf "%s\n" "${opciones[@]}" | gum choose --header="🛡️ VPN-ISAÍAS · Menú principal")

  case "$opcion" in
    "🔌 Conectar a una VPN") conectar_vpn ;;
    "📊 Ver información de la VPN activa") mostrar_info_vpn_activa ;;
    "🧾 Ver log de conexiones") mostrar_logs ;;
    "🔻 Desconectar VPN activa") desconectar_vpn ;;
    "❌ Salir") break ;;
  esac
done

clear
gum style --foreground 7 --italic --margin "1" "vpn-isaias · Script creado por Isaías FL · github.com/isaiasfl"

