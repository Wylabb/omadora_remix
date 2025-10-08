abort() {
  echo -e "\e[31mOmadora install requires: $1\e[0m"
  echo

  read -p "Proceed anyway on your own accord and without assistance? [y/N] " response
  case "$response" in
    [yY][eE][sS]|[yY]) ;;
    *) exit 1 ;;
  esac
}

# Must be a Fedora distro
[[ -f /etc/fedora-release ]] || abort "Fedora"

# Must not be running as root
[ "$EUID" -eq 0 ] && abort "Running as user (not root)"

# Must be a supported architecture
arch=$(uname -m)
case "$arch" in
  x86_64|aarch64)
    export OMADORA_ARCH="$arch"
    ;;
  *)
    abort "x86_64 or aarch64 CPU"
    ;;
esac

echo "Detected architecture: $OMADORA_ARCH"

# Should be a minimal/core only install
mapfile -t installed_groups < <(dnf group list --installed --hidden -q \
  | sed -nE 's/^[[:space:]]{2,}//p' \
  | awk 'NF {print tolower($0)}')

allowed_groups=("core" "minimal install")
declare -a unexpected_groups=()

for group in "${installed_groups[@]}"; do
  # Skip duplicate lines that can appear when no groups are installed
  [[ -z "$group" ]] && continue

  allowed=false
  for allowed_group in "${allowed_groups[@]}"; do
    if [[ "$group" == "$allowed_group" ]]; then
      allowed=true
      break
    fi
  done

  $allowed || unexpected_groups+=("$group")
done

if (( ${#unexpected_groups[@]} )); then
  abort "Core or Minimal Fedora install (unexpected groups: ${unexpected_groups[*]})"
fi

# Cleared all guards
echo "Guards: OK"
