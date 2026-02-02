#!/bin/sh

# 1. Cấu hình biến môi trường
ROOTFS_DIR=$(pwd)
PROOT_BIN="/tmp/proot"
ARCH=$(uname -m)

# 2. Kiểm tra kiến trúc CPU
if [ "$ARCH" = "x86_64" ]; then
  ARCH_ALT=amd64
elif [ "$ARCH" = "aarch64" ]; then
  ARCH_ALT=arm64
else
  printf "Unsupported CPU architecture: ${ARCH}\n"
  exit 1
fi

# 3. Tải Ubuntu Base (chỉ tải nếu chưa installed)
if [ ! -e "$ROOTFS_DIR/.installed" ]; then
  echo "--- Downloading Ubuntu RootFS ---"
  wget --no-hsts -O /tmp/rootfs.tar.gz \
    "http://cdimage.ubuntu.com/ubuntu-base/releases/24.04/release/ubuntu-base-24.04.3-base-${ARCH_ALT}.tar.gz"
  tar -xf /tmp/rootfs.tar.gz -C "$ROOTFS_DIR"
  
  # Cấu hình DNS cơ bản
  printf "nameserver 1.1.1.1\nnameserver 1.0.0.1" > "${ROOTFS_DIR}/etc/resolv.conf"
  touch "$ROOTFS_DIR/.installed"
fi

# 4. Tải và xử lý PRoot vào /tmp (Nơi có quyền thực thi)
echo "--- Setting up PRoot in /tmp ---"
if [ ! -f "$PROOT_BIN" ]; then
  wget --no-hsts -O "$PROOT_BIN" "https://raw.githubusercontent.com/foxytouxxx/freeroot/main/proot-${ARCH}"
fi

# Cấp quyền thực thi cực mạnh
chmod 777 "$PROOT_BIN"

# 5. Giao diện hoàn tất
CYAN='\e[0;36m'
RESET='\e[0m'
clear
echo -e "${CYAN}-----> Mission Completed ! <----${RESET}"

# 6. Chạy PRoot (Sử dụng binary từ /tmp nhưng mount rootfs từ thư mục hiện tại)
"$PROOT_BIN" \
  --rootfs="${ROOTFS_DIR}" \
  -0 -w "/root" \
  -b /dev -b /sys -b /proc -b /etc/resolv.conf \
  --kill-on-exit
