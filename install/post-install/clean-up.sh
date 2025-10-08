# Remove unwanted groups
declare -a groups=()
readarray -t groups < <(awk 'NF && $1 !~ /^#/' "$OMADORA_INSTALL/omadora-removed.groups")

if [[ -n "${OMADORA_ARCH:-}" ]]; then
  arch_groups_file="$OMADORA_INSTALL/omadora-removed.groups.$OMADORA_ARCH"
  if [[ -f "$arch_groups_file" ]]; then
    readarray -t arch_groups < <(awk 'NF && $1 !~ /^#/' "$arch_groups_file")
    groups+=("${arch_groups[@]}")
  fi
fi

if (( ${#groups[@]} )); then
  sudo dnf group remove -y "${groups[@]}"
fi

# Remove unwanted packages
declare -a packages=()
readarray -t packages < <(awk 'NF && $1 !~ /^#/' "$OMADORA_INSTALL/omadora-removed.packages")

if [[ -n "${OMADORA_ARCH:-}" ]]; then
  arch_packages_file="$OMADORA_INSTALL/omadora-removed.packages.$OMADORA_ARCH"
  if [[ -f "$arch_packages_file" ]]; then
    readarray -t arch_packages < <(awk 'NF && $1 !~ /^#/' "$arch_packages_file")
    packages+=("${arch_packages[@]}")
  fi
fi

if (( ${#packages[@]} )); then
  sudo dnf remove -y "${packages[@]}"
fi

# Remove NetworkManager configuration
sudo rm -rf /etc/NetworkManager
