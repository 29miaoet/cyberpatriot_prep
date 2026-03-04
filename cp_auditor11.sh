#!/bin/bash


# This is currently auditor version 11.0.
# This auditor is not responsible for any damages to your system, so please test it out on a VM.
# This auditor needs extensive testing.
# This script is interactive, please use with care.
# This auditor is only designed to be used on debian based systems, do not try to use it on any other Linux distributions unless you wish to crash them.
# The script is not POSIX portable.
# This auditor will repair about 80% of errors on basic level images and about 60% of errors on medium level images.
# Do not rely solely on this auditor to gather points.



# Sets opening configuration

RED=$'\033[41m'
GREEN=$'\033[42m'
YELLOW=$'\033[43m'
BLUE=$'\033[44m'
RESET=$'\033[0m'

echo_color() {
    local color="$1"
    shift
    local message="$*"
    echo -e "${color}${message}${RESET}" >> report.log
    #echo -e "${color}${message}${RESET}"
}


set -u
IFS=$'\n\t'

# ===================== STYLE FINISHES =====================
VERSION="11.0"
DRYRUN=0

section() {
  echo -e "\n${BLUE}========== $1 ==========${RESET}"
}

PROGRESS_TOTAL=0
PROGRESS_CURRENT=0
PROGRESS_WIDTH=29


draw_progress() {

  if (( PROGRESS_TOTAL == 0 )); then
    printf "\r[....................] 0/0" >&2
    return
  fi

  local filled=$(( PROGRESS_CURRENT * PROGRESS_WIDTH / PROGRESS_TOTAL ))
  local empty=$(( PROGRESS_WIDTH - filled ))

  printf "\r[" >&2
  printf "%0.s#" $(seq 1 "$filled") >&2
  printf "%0.s." $(seq 1 "$empty") >&2
  printf "] %d/%d" "$PROGRESS_CURRENT" "$PROGRESS_TOTAL" >&2

}

progress_start() {
  
  if [[ -z "${1:-}" ]]; then
     echo "progress_start: missing total count" >&2
     return 1
  fi
 
  PROGRESS_TOTAL="$1"
  PROGRESS_CURRENT=0
  #draw_progress
}

progress_end() {
  echo -ne "\033[8D \033[1D#"
  echo
}


log_ok()   {
  draw_progress
  ((PROGRESS_CURRENT++))
  echo_color "$GREEN"  "[ OK ] $*"
}
  
log_warn() {
  draw_progress
  ((PROGRESS_CURRENT++))
  echo_color "$YELLOW" "[WARN] $*"
}
  
log_err()  {
  draw_progress
  ((PROGRESS_CURRENT++))
  echo_color "$RED"    "[RISK] $*"
}
  
log_info() {
  echo_color "$BLUE"   "[INFO] $*"
}

confirm() {
  read -rp "$1 [y/N]: " reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

pause() {
  read -rp "Press ENTER to continue..."
}

run() {
  if (( DRYRUN )); then
    log_warn "[DRY-RUN] $*"
  else
    eval "$@"
  fi
}


# =================== END STYLE FINISHES ===================


# Provides the info block for the user, uses less to view by default.
info() {

	touch ~/Desktop/info.txt 2> /dev/null
	cat <<-EOF > ~/Desktop/info.txt
	
	When you are done reading, please exit with "q".
	
	This is auditor version 11.0.
	This auditor is not responsible for any damages to your system.
	This auditor needs extensive testing.
	This auditor is only designed to be used on debian based systems, do not try to use it on any other Linux distributions.
	The script is not POSIX portable.
	Use Ctrl+c to stop this script at any time.
	Do not use this script on the following debian-based systems: Proxmox VE, TurnKey Linux.
	Do not use this script on WSL.
	This auditor will repair about 80% of errors on basic level images and about 60% of errors on basic level images.
	Do not rely solely on this auditor to gather points.
	If you are using this auditor on a personal computer, please stop with Ctr+C, as it will strip all possibly suspicious directories and mp3 files.
	This auditor may flag legitimate mp3 or ogg files as suspicous, so please verify before deleting.
	Please verify the suspicious services flagged with the critical services provided by the readme before killing
	Only generalized issues are covered, specific problems or more difficult risks are not covered.
	Please read and answer all Forensics questions before using this auditor, as it will almost certainly remove something that will prevent you from answering correctly.
	This auditor will not enforce reliable security fixes, so please consult a credible source if you are actually planning on securing the computer.
	
	The issus below are covered by this auditor:
	
	Updates & full updates of system applications
	Root password locking
	Minimum password lengths
	Null password authentication issues
	Uncomplicated firewall protection
	Shadow file permissions
	Grub configuration file permissions
	SSH root login disable
	Unauthorized mp3 file removal
	Unauthorized ogg file removal
	Unauthorized application removal
	Automatic update enable*
	Remember previous passwords
	Ipv4 TCP SYN cookies definition
	Adress space randomization definition
	Ipv4 forwarding definition
	Default file permissions
	Removal of unauthorized users
	Removal of unauthorized administrators
	Removal of unauthorized users with sudo privileges
	Removal of unauthorized services
	Disabling of passwordless sudo
	Password aging rules
	User password aging rules
	Stripping any suspicious directories
	Stripping files in user Music directories
	Auditaid
	
	The issues below are automatically repaired by this auditor:
	
	Password aging rules
	User password aging rules
	Stripping any suspicious directories
	Stripping files in user Music directories
	
	The issues below are NOT covered by this auditor:
	
	Answering of Forensics questions
	Detection and removal of system backdoors
	Detection and removal of reverse shell scripts
	Detection and removal of malicious software
	Manipulation of hidden files
	Specific tasks specified by the readme file
	Other advanced system issues
	
	The issues below have not been thorougly tested and may bring harm to your computer
	
	Apt configuration on the GUI**
	Pam lockout policies / authentication errors
	
	If these issues arise, please do the following:
	The update manager reports that apt configuration is corrupt:
	If you are on Ubuntu:
	  1. Open "software & updates" on Ubuntu.
	  2. Click on the "Ubuntu software" tab.
	  3. Click the dropdown menu after the "Download from" option, and select "Server for United States"
	  4. Click close and authenticate to apply changes.
	
	If you are on Mint:
	  1. Open "software manager"
	  2. Click on "switch to a local mirror".
	  3. Select a local mirror or click on "restore default locations".
	  4. Close and authenticate to apply change.
	
	Pam lockout policies / Authentication errors:
	  1. Open you're terminal and paste this into it:
	     sudo rm /usr/share/pam-configs/faillock
		 sudo rm /usr/share/pam-configs/faillock_reset
		 sudo rm /usr/share/pam-configs/faillock_notify
		 sudo sed -i '/pam_faillock.so/d' /etc/pam.d/common-auth
		 or:
	     sudo rm /usr/share/pam-configs/faillock
		 sudo rm /usr/share/pam-configs/faillock_reset
		 sudo rm /usr/share/pam-configs/faillock_notify
		 sudo nano /etc/pam.d/common-auth
		 delete any lines containing "pam_faillock.so"
	  2. Paste this into you're terminal:
	     sudo pam-auth-update
		 Press "TAB", then "ENTER" or "SPACE".
	  3. Reboot.
	
	Auditaid is a newly written script that helps the user configre and audit the system in a simple, option menu with less danger of misconfiguration.
	To access it, select "Advanced Options" in the startup menu.
	This version will provide help with basic level forensics questions.
	
	*Automatic updates will be enabled on this system, however,the GUI update manager will not read it; if you want to gain points, please follow these steps:
	If you are on Ubuntu:
	  1. Open "software & updates" on Ubuntu.
	  2. Navigate to "Updates".
	  3. Click on the dropdown menu after "Automatically check for updates:".
	  4. Select "Daily".
	  5. Authenticate and close.
	
	If you are on Mint:
	  1. Open "software manager".
	  2. Navigate to "preferences", "automation", and then toggle "enable updates automatically" on, you may need to provide administrator level authentication.
	  3. Close and save.
	  
	**If the update manager reports that the apt configuration is corrupt, it may be due to this program; however, apt is not really broken, it will still work perfectly through the terminal, and if you want it to be available from the Graphical User Interface as well, please follow the instructions under "The update manager reports that apt configuration is corrupt."
	
	EOF

	less ~/Desktop/info.txt


}

# Scans the system for simple security vulnerabilities.


scan() {

  risks=0
  aptupdt=0
  snapupdt=0
  shadow=0
  minlen=0
  nullok=0
  ufw=0
  shadowperm=0
  grubperm=0
  rtlogin=0
  mp3=0
  appy=0
  auto_upgrade=0
  faillock=0
  faillock_notify=0
  faillock_reset=0
  f_lock=0
  common_auth=0
  ogg=0
  remember=0
  ipv4_tcp=0
  adrando=0
  ipv4_forward=0
  umsk=0

  echo -e "$YELLOW""Scanning system, this may take a while...${RESET}"
  echo
  if apt list --upgradable 2>> errors.log | grep -q upgradable; then
    log_err "Apt updates are available."
    ((risks++))
    aptupdt=1
  else
    log_ok "Apt updates are installed."
  fi
  
  if [[ -z $(snap refresh --list 2>> errors.log) ]]; then
    log_ok "Snap updates are installed."
  else
    log_err "Snap updates are available."
    ((risks++))
    snapupdt=1
  fi
  
  

  if sudo passwd -S root | grep -q "NP"; then
    log_err "Root password is insecure."
    ((risks++))
    shadow=1
  elif [ -z $(sudo getent passwd root | cut -d: -f 2) ]; then
    log_err "Root password is blank."
    ((risks++))
    shadow=1
  else
	log_ok "Root password is filled."
  fi
  


  if ! grep -q 'minlen=' /etc/pam.d/common-password; then
    log_err "There is no minimum password length."
    ((risks++))
    minlen=1
  else
    minlen_val=$(grep -oP '(?<=minlen=)\d+' /etc/pam.d/common-password | head -1)
    log_ok "Minimum password length is $minlen_val"
	
	#Might add more here
  fi


  if ! grep -q 'remember=' /etc/pam.d/common-password; then
    log_err "Previous passwords are not remembered."
    ((risks++))
    remember=1
  else
    remember_val=$(grep -oP '(?<=remember=)\d+' /etc/pam.d/common-password | head -1)
    log_ok "Last $remember_val passwords are remembered."
  fi


  if grep -Eq 'pam_unix\.so.*nullok' /etc/pam.d/common-auth; then
    log_err "Null passwords authenticate."
    ((risks++))
    nullok=1
  else
    log_ok "Null passwords do not authenticate."
  fi

  if sudo ufw status | grep -q "Status: inactive"; then
    log_err "Firewall is inactive."
    ((risks++))
    ufw=1
  else
    log_ok "Firewall is active."
  fi

  perm=$(stat -c "%a" /etc/shadow)
  if [[ "$perm" != "640" && "$perm" != "600" ]]; then
    log_err "Insecure permissions on shadow file."
    ((risks++))
    shadowperm=1
  else
    log_ok "Permissions on shadow file are secure."
	
  fi
  
  germ=$(stat -c "%a" /boot/grub/grub.cfg)
  if [[ -z $(locate /boot/grub/grub.cfg) ]]; then 
    log_warn "Grub configuration file is missing, skipping grub permission check."
  elif [[ "$germ" != "600" ]]; then
    log_err "Insecure permissions on grub configuration file."
    ((risks++))
    grubperm=1
  else
    log_ok "Permissions on grub configuration file is secure."

  fi

  if [[ -f /etc/ssh/sshd_config ]]; then
    if grep -Eq '^\s*PermitRootLogin\s+yes' /etc/ssh/sshd_config; then
      log_err "Root login is enabled."
      ((risks++))
      rtlogin=1
    elif ! grep -Eq '^\s*PermitRootLogin\s+no' /etc/ssh/sshd_config; then
      log_err "Root login is not defined."
      ((risks++))
      rtlogin=1
    else
      log_ok "Root login is not permitted."
    fi
  else
    log_warn "SSH config missing; skipping root login check."
  fi

  if sudo locate '*.mp3' 2>> errors.log | grep -q .; then
    log_warn "Unauthorized mp3 files may exist on this computer."
    ((risks++))
    mp3=1
  else
    log_ok "No unauthorized mp3 files on this computer."
  fi

  if sudo locate '*.ogg' 2>> errors.log | grep -q .; then
    log_warn "Unauthorized ogg files may exist on this computer."
    ((risks++))
    ogg=1
  else
    log_ok "No unauthorized ogg files on this computer."
  fi

  
  if [[ -z $(apt list --installed 2>/dev/null | grep -Eo 'ophcrack|wireshark|doona|xprobe|aisleriot|zangband') ]]; then
	log_ok "No unauthorized applications on this computer."
  else
	log_warn "Unauthorized applications may exist on this computer."
    ((risks++))
    appy=1
  fi

  conf="/etc/apt/apt.conf.d/20auto-upgrades"
  update_lists=$(grep -Po '(?<=Update-Package-Lists ")[01]' "$conf" 2>>errors.log)
  unattended=$(grep -Po '(?<=Unattended-Upgrade ")[01]' "$conf" 2>>errors.log)

  if [[ "$update_lists" != "1" || "$unattended" != "1" ]]; then
    log_err "Automatic updates not enabled."
    ((risks++))
    auto_upgrade=1
  else
    log_ok "Automatic updates are enabled."
  fi
  
  if [ -f /usr/share/pam-configs/faillock ]; then
    log_ok "faillock is configured."
  else
    log_err "faillock not configured."
	((risks++))
	faillock=1
	((f_lock++))
  fi
  
  if [ -f /usr/share/pam-configs/faillock_notify ]; then
    log_ok "faillock notify is configured."
  else
    log_err "faillock notify not configured."
	((risks++))
	faillock_notify=1
	((f_lock++))
  fi
  
  if [ -f /usr/share/pam-configs/faillock_reset ]; then
    log_ok "faillock reset is configured."
  else
    log_err "faillock reset not configured."
	((risks++))
	faillock_reset=1
	((f_lock++))
  fi
  
  if [[ $faillock == 1 || $faillock_notify == 1 || $faillock_reset == 1 ]]; then
    log_err "$f_lock lockout policies are not configured."
  fi
  
  # Problem fixed?
  if [[ -z $(grep "auth required pam_faillock.so" /etc/pam.d/common-auth) || -z $(grep "auth \[default=die\] pam_faillock.so" /etc/pam.d/common-auth) || -z $(grep "auth sufficient pam_faillock.so" /etc/pam.d/common-auth) ]]; then
	log_err "Certain pam modules are not readable."
	((risks++))
	common_auth=1
  fi
  
  if [[ -f /etc/sysctl.conf ]]; then
    if sudo grep -Eq '^\s*net.ipv4.tcp_syncookies=0' /etc/sysctl.conf; then
      log_err "IPv4 TCP SYN cookies are not enabled."
      ((risks++))
      ipv4_tcp=1
    elif ! sudo grep -Eq '^\s*net.ipv4.tcp_syncookies=1' /etc/sysctl.conf; then
      log_err "IPv4 TCP SYN cookies are not defined."
      ((risks++))
      ipv4_tcp=1
    else
     log_ok "IPv4 TCP SYN cookies are enabled."
    fi
  else
    log_warn "sysctl.conf missing; skipping ipv4 cookie check."
  fi
  
  if [[ -f /etc/sysctl.conf ]]; then
    if sudo grep -Eq '^\s*kernel.randomize_va_space=0' /etc/sysctl.conf; then
      log_err "Adress space layout randomization is not enabled."
      ((risks++))
      adrando=1
    elif ! sudo grep -Eq '^\s*kernel.randomize_va_space=2' /etc/sysctl.conf; then
      log_err "Adress space layout randomization is not defined."
      ((risks++))
      adrando=1
    else
      log_ok "Adress space layout randomization is enabled."
    fi
  else
    log_warn "sysctl.conf missing; skipping ipv4 address randomization check."
  fi

  if [[ -f /etc/sysctl.conf ]]; then
    if sudo grep -Eq '^\s*net.ipv4.ip_forward=1' /etc/sysctl.conf; then
      log_err "IPv4 forwarding is enabled."
      ((risks++))
      ipv4_forward=1
    elif ! sudo grep -Eq '^\s*net.ipv4.ip_forward=0' /etc/sysctl.conf; then
      log_err "IPv4 forwarding is not defined."
      ((risks++))
      ipv4_forward=1
    else
      log_ok "IPv4 forwarding is not enabled."
    fi
  else
    log_warn "sysctl.conf missing; skipping ipv4 forwarding check."
  fi
  
  if [[ $(umask) != 0027 && $(umask) != 0077 ]]; then
    log_err "File default permissions are not secure."
	((risks++))
	umsk=1
  else
    log_ok "File default permissions are secure."
  fi
 
}

#STOPPED HERE
# Please keep the commented codes in this section as a safe backup.
# Searches for unauthorized users and admins and removes them.
# It may flag system admin accounts as unauthorized.

userscan() {

  unauthu=0
  unautha=0
  unauths=0

  #Get all human users (UID 1000–60000), ignore system users
  unauthorized_users=$(awk -F: '$3 >= 1000 && $3 < 60000 {print $1}' /etc/passwd | grep -Fxv -f authorized_users.txt)
  unauthorized_admins=$(getent group adm | cut -d: -f4 | tr ',' '\n' | grep -Fxv -f authorized_admins.txt)
  mapfile -t unauthorized_admins < <(
  getent group adm sudo \
  | cut -d: -f4 \
  | tr ',' '\n' \
  | grep -v '^$' \
  | sort -u \
  | grep -Fxv -f authorized_admins.txt
  )

  mapfile -t unauthorized_sudoers < <(
  getent group sudo \
  | cut -d: -f4 \
  | tr ',' '\n' \
  | grep -v '^$' \
  | sort -u \
  | grep -Fxv -f authorized_admins.txt
  )

  [[ -n "$unauthorized_users" ]] && log_err "Unauthorized users detected!\n$unauthorized_users" && unauthu=1 || log_ok "No unauthorized users detected."


  if (( ${#unauthorized_admins[@]} > 0 )); then
    log_err "Unauthorized administrators detected!"
    unautha=1
    for admin in "${unauthorized_admins[@]}"; do
        echo_color "$RED" "$admin"
    done
  else
    log_ok "No unauthorized administrators detected."
  fi

  #[[ -n "${unauthorized_sudoers[@]}" ]]  && log_err $'Unauthorized sudoers detected!\n'"${unauthorized_sudoers[@]}" && unauths=1 || log_ok "No unauthorized sudoers detected."
  if (( ${#unauthorized_sudoers[@]} > 0 )); then
    log_err $'Unauthorized sudoers detected!\n'"${unauthorized_sudoers[*]}"
    unauths=1
  else
    log_ok "No unauthorized sudoers detected."
  fi

  
}

adv_scan() {

  pswdls=0
  services=0
  uservice=0
  pass_age=0

  services=$(systemctl list-units --type=service --state=running | grep -Eo 'nginx|apache|apache2|ssh|vsftpd|mysql|postgres|squid|mariadb|haproxy')
  if [[ -z $services ]]; then 
    log_ok "No suspicious services are running."
  else
    log_warn "Some suspicious services may be running."
    ((risks++))
    uservice=1
  fi


  if [[ -z $(sudo grep -R "NOPASSWD" /etc/sudoers.d 2>> errors.log | grep -v '^#') ]]; then
    pswdls=1
    ((risks++))
	log_err "Passwordless sudo is enabled."
  else
    log_ok "Passwordless sudo not enabled."
  fi

  if grep -Eq '^[[:space:]]*PASS_MAX_DAYS[[:space:]]+90' /etc/login.defs \
   && grep -Eq '^[[:space:]]*PASS_MIN_DAYS[[:space:]]+1' /etc/login.defs \
   && grep -Eq '^[[:space:]]*PASS_WARN_AGE[[:space:]]+14' /etc/login.defs
  then
    log_ok "Password aging rules are secure."
  else
    log_err "Password aging rules are not secure."
	((risks++))
	pass_age=1
  fi
  
  log_info "28 insecurities scanned, $risks risks detected."
}

# Fixes common security risks, tested.

fix() {
  echo "Installing updates, this may take a while, please keep the terminal open."
  [[ $aptupdt -eq 1 ]] && sudo apt upgrade -y && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean && sudo apt upgrade -y && echo "Apt updates are installed."
  [[ $snapupdt -eq 1 ]] && sudo snap refresh && echo "Snap updates are installed."
  [[ $shadow -eq 1 ]] && sudo passwd -l root 
  [[ $minlen -eq 1 ]] && sudo sed -i 's/pam_unix.so/& minlen=10/' /etc/pam.d/common-password 
  [[ $remember -eq 1 ]] && sudo sed -i 's/pam_unix.so/& remember=3/' /etc/pam.d/common-password
  [[ $nullok -eq 1 ]] && sudo sed -i 's/nullok//' /etc/pam.d/common-auth 
  [[ $ufw -eq 1 ]] && sudo ufw enable 
  [[ $shadowperm -eq 1 ]] && sudo chmod 640 /etc/shadow
  [[ $grubperm -eq 1 ]] && sudo chmod 600 /etc/boot/grub/grub.cfg
  [[ $rtlogin -eq 1 ]] && sudo sed -i 's/PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config 
  [[ $ipv4_tcp -eq 1 ]] && sudo sed -i 's/net.ipv4.tcp_syncookies=.*/net.ipv4.tcp_syncookies=1/' /etc/sysctl.conf && sudo sysctl -p
  [[ $adrando -eq 1 ]] && sudo sudo sed -i 's/kernel.randomize_va_space=.*/kernel.randomize_va_space=2/' /etc/sysctl.conf && sudo sysctl -p
  [[ $ipv4_forward -eq 1 ]] && sudo sed -i 's/net.ipv4.ip_forward=.*/net.ipv4.ip_forward=0/' /etc/sysctl.conf && sudo sysctl -p
  [[ $umsk -eq 1 ]] && umask 27
  [[ $pass_age -eq 1 ]] && sudo sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs && sudo sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   1/' /etc/login.defs && sudo sed -i  's/^PASS_WARN_AGE.*/PASS_WARN_AGE   14/' /etc/login.defs

	
  if [ $auto_upgrade = 1 ]; then
    sudo apt install -y unattended-upgrades
	sudo debconf-set-selections <<<  'unattended-upgrades unattended-upgrades/enable_auto_updates boolean true'
  fi
  
  if [ $unauthu = 1 ]; then
    mapfile -t userr <<< "$unauthorized_users"

    for user in "${userr[@]}"; do
        echo "delete user $user [y/n]?"
		read ANSWER
		if [ "$ANSWER" = "y" ]; then
		  sudo deluser "$user"
                  echo "Removed user $user"
		else
		  echo "Remove user cancelled."
		fi
    done
	
  fi
 
  if [ $unautha = 1 ]; then
    mapfile -t usera <<< "$unauthorized_admins"

    for adm in "${usera[@]}"; do
        echo "change administrator $adm to regular user? [y/n]?"
		read ANSWER
		if [ "$ANSWER" = "y" ]; then
		  sudo delgroup "$adm" adm
		  sudo delgroup "$adm" sudo
                  echo "$adm is no longer administrator."
		else
		  echo "Change administrator cancelled."
		fi
    done
	
  fi 
  
  
  if [ $unauths = 1 ]; then
    mapfile -t users <<< "$unauthorized_sudoers"

    for sud in "${users[@]}"; do
        echo "change sudoer $sud to regular user? [y/n]?"
		read ANSWER
		if [ "$ANSWER" = "y" ]; then
		  sudo delgroup "$sud" sudo
                  echo "$sud is no longer sudoer."
		else
		  echo "Change sudoer cancelled."
		fi
    done
	
  fi 

  
  if [ $pswdls = 1 ]; then
    # Remove all NOPASSWD entries in /etc/sudoers.d
    sudo grep -R "NOPASSWD" /etc/sudoers.d 2>> errors.log \
        | cut -d: -f1 \
        | sort -u \
        | xargs -r sudo rm

    # Test if passwordless sudo still works
	sudo find /etc/sudoers.d -type f -exec sed -i '/NOPASSWD/d' {} +
	# Validate sudoers syntax
	sudo visudo -c
  fi

  
  
  
  
  if [ $mp3 = 1 ]; then 
    mapfile -t mp3s <<< "$(locate '*.mp3' 2>/dev/null)"

    for unauth_mp3 in "${mp3s[@]}"; do
        echo "Delete unauthorized mp3 file $unauth_mp3? [y/n]?"
		read ANSWER
		if [ "$ANSWER" = "y" ]; then
		  sudo rm -v "$unauth_mp3"
          echo "$unauth_mp3 deleted."
		else
		  echo "$unauth_mp3 not deleted."
		fi
    done
  fi
  
  
  if [ $ogg = 1 ]; then 
    mapfile -t oggs <<< "$(locate '*.ogg' 2>/dev/null)"

    for unauth_ogg in "${oggs[@]}"; do
        echo "Delete unauthorized ogg file $unauth_ogg? [y/n]?"
		read ANSWER
		if [ "$ANSWER" = "y" ]; then
		  sudo rm -v "$unauth_ogg"
          echo "$unauth_ogg deleted."
		else
		  echo "$unauth_ogg not deleted."
		fi
    done
  fi
  
    
  
  if [ $appy = 1 ]; then 
    mapfile -t appy <<< "$(apt list --installed 2>/dev/null | grep -Eo 'ophcrack|wireshark|doona|xprobe|aisleriot' )"

    for unauth_app in "${appy[@]}"; do
        echo "Uninstall suspicious application $unauth_app? [y/n]?"
        read ANSWER
	if [ "$ANSWER" = "y" ]; then
	  sudo apt purge -y "$unauth_app"
	  sudo apt autoremove -y
          echo "$unauth_app uninstalled."
        else
          echo "$unauth_app not uninstalled."
	fi
    done
  fi


  if [ "$uservice" = "1" ]; then 
    mapfile -t serve <<< "$services"

    for unauth_serve in "${serve[@]}"; do
        echo "Kill suspicious service $unauth_serve? [y/n]?"
        read ANSWER
     if [ "$ANSWER" = "y" ]; then
        sudo systemctl disable --now $unauth_serve
        echo "$unauth_serve killed."
     else
        echo "$unauth_serve not killed."
     fi
    done

  fi
  
  for u in $(awk -F: '$3 >= 1000 {print $1}' /etc/passwd); do
    sudo chage --maxdays 90 "$u" > /dev/null
  done
  
  for u in $(awk -F: '$3 < 1000 {print $1}' /etc/passwd); do
    sudo usermod -s /usr/sbin/nologin "$u" > /dev/null
  done
  
  
  echo "Strip suspicious directories?"
  pause
  sudo rm -r /usr/games 2> /dev/null
  sudo rm -rf /home/*/Music/* 2>/dev/null
  sudo rm -rf /home/*/games/* 2>/dev/null



}

auditaid() {
  echo -e "${BLUE}~~~~~~~~~~~~~~~~Advanced Options~~~~~~~~~~~~~~~~${RESET}"
  echo
  echo "1.Add a user to the system.                --(a)"
  echo "2.Add a user to a group.                   --(b)"
  echo "3.Add a group to the system.               --(c)"
  echo "4.Remove a group from the system.          --(d)"
  echo "6.Install or update an application.        --(e)"
  echo "7.Install and/or start a service.          --(f)"
  echo "8.Stop or kill a service.                  --(g)"
  echo "9.Change insecure password for a user.     --(h)"
  echo "10.Find and remove a backdoor.             --(i)"
  echo "11.Get help on a forensics question.       --(j)"
  echo "12.Exit advanced options.                  --(k)"
  echo
  echo -n "select an option to continue: "
  read RESPONSEA
  echo
    if [[ "$RESPONSEA" = "a" ]]; then 
		echo -n "Enter the name of the user you want to add: "
		read USERNAME
		sudo useradd -m -s /bin/bash "$USERNAME"
		[[ $? -eq 0 ]] && echo "Setting a password for $USERNAME"
		[[ $? -eq 0 ]] && sudo passwd "$USERNAME"
		[[ $? -eq 0 ]] && echo -e "${GREEN}Added user $USERNAME.${RESET}" || echo -e "${RED}Failed to add user $USERNAME.${RESET}"
		echo
    fi

    if [[ "$RESPONSEA" = "b" ]]; then
		echo -n "Enter the name of the group you want to add to: "
		read GROUPNAME
		echo -n "Enter the name of the user you want to add: "
		read USERGROUP
		sudo gpasswd -a "$USERGROUP" "$GROUPNAME"
     		[[ $? -eq 0 ]] && echo -e "${GREEN}Added $USERGROUP to $GROUPNAME.${RESET}" || echo -e "${RED}Failed to add $USERGROUP to $GROUPNAME.${RESET}"
		echo
    fi
    if [[ "$RESPONSEA" = "c" ]]; then 
		echo -n "Enter the name of the group you want to add: "
		read ADDGRP
		groupadd $ADDGRP && echo -e "${GREEN}Added group $ADDGRP.${RESET}" || echo -e "${RED}Failed to add group $ADDGRP.${RESET}"
		echo
    fi
    if [[ "$RESPONSEA" = "d" ]]; then 
		echo -n "Enter the name of the group you want to delete: "
		read DELGRP
		groupdel $DELGRP && echo -e "${GREEN}Deleted group $DELGRP.${RESET}" || echo -e "${RED}Failed to delete group $DELGROUP.${RESET}"
		echo
    fi 
	if [[ "$RESPONSEA" = "e" ]]; then
		echo -n "Enter package name to install: "
		read pkg
		if apt-cache policy $pkg | grep -q "Candidate:"; then
			echo "Verify that this is the package you wish to install? (y/n) "
			echo "$pkg"
			read ANSWER 
			[[ $ANSWER = y ]] && sudo apt install $pkg && echo -e "${GREEN}$pkg installed and updated.${RESET}" || echo "Returning to menu."
			echo
		elif snap search $pkg | grep -q "$pkg"; then
			echo "Snap packages are not supported, insist on installing this package?"
			echo "$pkg"
			sudo snap install $pkg
			echo
		else
			echo -e "${RED}Error!! Package $pkg not found.${RESET}"
			echo
		fi
    fi  
	if [[ "$RESPONSEA" = "f" ]]; then
		echo -n "Enter service name to install: "
		read ser
		echo "Verify that this is the service you wish to install? (y/n) "
		echo "$ser"
		read ANSWER 
		[[ $ANSWER = y ]] && (sudo apt install -y "$ser" && echo -e "${GREEN}$ser installed.${RESET}" && (sudo systemctl start "$ser" && echo -e "${GREEN}$ser started.${RESET}" || echo "$ser is not a service or failed to start") || echo -e "${RED}Error!! Package $ser not found.${RESET}") || echo "Returning to menu."
		echo
	fi 
	if [[ "$RESPONSEA" = "g" ]]; then
		echo -n "Enter service name to stop: "
		read SERSTOP
		sudo systemctl stop $SERSTOP
		[[ "$?" = "0" ]] && echo "$SERSTOP stopped, permanantly kill and remove this service?"
		read ANSWER
		preexit=0
		if [[ "$ANSWER" = y ]]; then
			sudo systemctl disable $SERSTOP && sudo systemctl mask $SERSTOP && preexit=1 || echo -e "${RED}Failed to stop $SERSTOP.${RESET}"
			sudo rm /etc/systemd/system/${SERSTOP}.service 2>/dev/null ; sudo rm /lib/systemd/system/${SERSTOP}.service 2>/dev/null ; sudo rm /usr/lib/systemd/system/${SERSTOP}.service 2>/dev/null
			[[ "$preexit" = 1 ]] && sudo systemctl daemon-reload && echo -e "${GREEN}$SERSTOP killed and removed."
		fi
		echo
	fi
	if [[ "$RESPONSEA" = "h" ]]; then
		echo -n "Enter username: "
		read USRNM
		sudo passwd $USRNM && echo -e "${GREEN}Password for $USRNM has been changed.${RESET}" || echo -e "${RED}Error encountered, password not changed.${RESET}"
		echo
	fi
	if [[ "$RESPONSEA" = "i" ]]; then
		exitcode=0
		echo -n "Enter the nature of the process (e.g. python, cron, journald): "
		read PROCESS
		sudo ps -ef | sudo grep "$PROCESS" && exitcode=1
		while [[ "$exitcode" != 1 ]]; do
			echo "$PROCESS not found, maybe try another keyword?"
			read $PROCESS
			sudo ps -ef | sudo grep "$PROCESS" && exitcode=1
		done
		echo "The folowing processes are running: "
		echo $PROCESS
		echo -n "Please identify any backdoors by entering the PID (second row): "
		read PID
		echo "Kill this process?"
		pause
		sudo kill $PID
		path2process="$(readlink -f /proc/${PID}/exe)"
		echo "Confirm that this is the path to the backdoor: $path2process"
		read ANSWER
		[[ "$ANSWER" = y ]] && sudo rm -f  $path2process && echo -e "${GREEN}$path2process removed.${RESET}"  && sudo kill $PID || echo -e "${RED}Error, $path2process not killed.${RESET}"		
		echo
	fi
	if [[ "$RESPONSEA" = "j" ]]; then
		echo "${BLUE}~~~~~~~~~~~~~~~~~~~~~~Forensics Questions~~~~~~~~~~~~~~~~~~~~~~${RESET}"
		echo
		echo "Asks for codename of your current linux distribution.     --(1)"
		echo "Asks for absolute path of prohibited mp3 files.           --(2)"
		echo "Asks to decode a Base64 message.                          --(3)"
		echo "Asks for md5 sum of a file.                               --(4)"
		echo "Return to menu.                                           --(5)"
		echo
		echo -n "Enter the number of the type of question you wish to get help on: "
		read forensics
		echo
		if [[ $forensics -eq 1 ]]; then lsb_release -c 2>/dev/null && echo
		elif [[ $forensics -eq 2 ]]; then sudo locate '*.mp3' 2>/dev/null && echo "All mp3 files are shown above, please select the ones you think are relevant." || echo -e "${RED}No mp3 files were found.${RESET}" && echo
		elif [[ $forensics -eq 3 ]]; then echo "Please paste the message you wish to decode below: " && read BASE64 && echo "$BASE64" | base64 -d || echo -e "${RED}Message is not in base64 format.${RESET}" && echo
		elif [[ $forensics -eq 4 ]]; then echo "Please enter the absolute path to the file you wish to md5 below: " && read MD5 && sudo md5sum $MD5 | cut -d ' ' -f 1 || echo -e "${RED}File $MD5 not found.${RESET}" && echo
		elif [[ $forensics -eq 5 ]]; then echo
		fi
	fi
	[[ "$RESPONSEA" = "k" ]]

}


#Gives a full system report


sysreport() {
  awk '!seen[$0]++' report.log > report.tmp && mv report.tmp report.log
  awk '!seen[$0]++' errors.log > errors.tmp && mv errors.tmp errors.log 
  sed -i '/^[[:space:]]*$/d' errors.log
  echo
  echo "System Reports:"
  echo
  cat report.log
  echo
  echo "Errors encountered:"
  echo
  cat errors.log
  echo
}

# Newly added program menu.

menu() {
  echo -e "${BLUE}====Cyberpatriot Audit and Defense Utility====${RESET}"
  echo
  echo "Look for security issues.               --(1)"
  echo "Look for and repair security issues.    --(2)"
  echo "View more information.                  --(3)"
  echo "Advanced options.                       --(4)"
  echo "Quit the program.                       --(5)"
  echo
  echo -n "select an option to continue: "
  read RESPONSE
  echo
} 


#Actual file run

control=0
while [[ $control != 1 ]]; do
	echo
	menu
	if [[ $RESPONSE -eq 1 ]]; then 
		mkdir ~/Desktop/audits_and_reports
		mv ~/Desktop/info.txt ~/Desktop/audits_and_reports/info.txt 2>/dev/null
		cd ~/Desktop/audits_and_reports && touch report.log errors.log
		progress_start 25
		scan
		adv_scan
		progress_end
		sysreport
		control=1
		cd ..
		rm -r audits_and_reports
	fi
	[[ $RESPONSE -eq 3 ]] && info
	[[ $RESPONSE -eq 4 ]] && auditaid && control=1
	[[ $RESPONSE -eq 5 ]] && control=1


  if [[ $RESPONSE -eq 2 ]]; then 
	mkdir -p ~/Desktop/audits_and_reports
	cd ~/Desktop/audits_and_reports || exit 1
	: > report.log
	: > errors.log
	: > authorized_admins.txt
	: > authorized_users.txt
	mv ~/Desktop/info.txt ~/Desktop/audits_and_reports/info.txt 2>/dev/null
	echo 'A new directory, audits_and_reports, has been created.'
	echo 'Please fill in the authorized users and admins files with the relevant information.'
	echo 'When you are done, please reply "c" to continue.'
	read ANSWERC

	[[ "$ANSWERC" != "c" ]] && exit 1

	sudo -v || exit 1
	progress_start 28
	scan
	adv_scan
	userscan
	progress_end
	sysreport

	echo "Do you want to repair all errors? [y/n]"
	read ANSWERX
	if [[ "$ANSWERX" == "y" ]]; then
		fix
		truncate -s 0 report.log
		truncate -s 0 error.log
		scan
		adv_scan
		userscan
		sysreport
		echo "$risks risks fixed."
	fi
	

	# Conmment these 2 lines to keep the created directory.
	#============================================#
	cd ..
	sudo rm -r audits_and_reports
	#============================================#
	control=1
	
  fi
done

# Keep this line for easy format transfer
