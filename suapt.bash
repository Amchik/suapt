#!/bin/bash

unset suapt
suapt() {
  has() {
    which $@ 2> /dev/null > /dev/null
    return $?
  }
  runasroot() {
    local args="$@"
    has sustorage && local sus=1 || local sus=0
    has doas && local das=1 || local das=0
    has sudo && local sdo=1 || local sdo=0
    has su && local su=1 || local su=0
    if [[ $sus -ne 0 ]]; then
      sustorage prompt root "$@"
    elif [[ $das -ne 0 ]]; then
      doas -u root "$@"
    elif [[ $sdo -ne 0 ]]; then
      sudo "$@"
    elif [[ $su -ne 0 ]]; then
      su -c "$args"
    else
      echo -e "\e[31mFATAL:\e[0m no provider found for @runasroot\n" \
        "  Check suapt -su or suapt -version (@runasroot fallback providers)" > /dev/stderr
      printf '%s' "$args"
      return 255
    fi
    return $?
    #
    if ! which sustorage >/dev/null 2>&1; then
      su -c "$args"
    else
      sustorage prompt root $@
    fi
  }
  if [[ "$1" = "-version" ]]; then
    local ctc="\e[0;34m"
    [[ "$IDIOT_MODE" = "1" ]] && local cbc="\e[0;33m" || local cbc="$ctc"
    local aptv=$(apt --version 2>/dev/null)
    [[ "$aptv" = "" ]] && local aptv="not installed"
    local sustorage=$(sustorage revision 2>/dev/null)
    local notav="\e[1;31m"
    local nc="\e[0m"
    local ok=""
    local b="\e[1m"
    local sup=$(su -V 2>/dev/null)]
    has su && local sup=$ok || local sup=$notav
    has doas && local doasp=$ok || local doasp=$notav
    has sudo && local sudop=$ok || local sudop=$notav
    has sustorage && local susp=$ok || local susp=$notav
    [[ $sustorage = "" ]] && sustorage="none"
    echo    "suapt -- like su -c 'apt...', without sudo"
    echo -e "  version:    \e[1m0.9.3\e[0m"
    echo -e "  sustorage:  \e[1m$sustorage\e[0m"
    echo -e "  apt:        \e[1m${aptv#apt }\e[0m"
    echo -e "  @runasroot:$susp sustorage$nc$doasp doas$nc$sudop sudo$nc$sup su$nc"
    echo    "   -- By priority: if first not found second will be used etc"
    echo -e "   -- For get providers of @runasroot use$b suapt -su$nc"
    echo
    echo -e "src: Amchik/suapt    $ctc __   __   \e[0m"
    echo -e "                $ctc ____/ /  / /__ \e[0m"
    echo -e "Made by ${ctc}ceh${cbc}eki  $cbc/ __/ _ \\/  '_/ \e[0m"
    echo -e "     with \e[35mlove  $cbc\\__/_//_/_/\\_\\  \e[0m"
    return 0
  fi
  local args="${@:2}"
  case "$1" in
    -su)
      local notav="\e[1;31mnot found\e[0m"
      local sup=$(su -V 2>/dev/null)
      [[ $sup = "" ]] && local sup=$notav || local sup="${sup#su from }"
      local doasp="found"
      has doas || local doasp=$notav
      local sudop=$(sudo --version 2>/dev/null | head -n1 2>/dev/null)
      [[ $sudop = "" ]] && local sudop=$notav || sudop="${sudop#Sudo }"
      local susp=$(sustorage revision 2>/dev/null)
      [[ $susp = "" ]] && local susp=$notav
      echo "running as root providers:"
      echo -e " sustorage: $susp"
      echo -e " doas:      $doasp"
      echo -e " sudo:      $sudop"
      echo -e " su:        $sup"
      if [[ "$sup" = "$notav" ]]; then
        echo -e "\e[31m--- !!! FAIR NOTICE !!! ---\e[0m"
        echo "You'r path are '$PATH'."
        echo "  Please recheck installed packages via suapt l --installed"
        echo "  or fix \$PATH. Default \$PATH are" 
        echo "  '/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin'."
        echo "For su (/bin/su, /usr/bin/su) install util-linux package"
      fi
      ;;
    i|install|add|require)
			runasroot apt install "${@:2}"
			return $?
      ;;
    rm|remove|de|dd|del|delet|delete)
      if [[ $# -eq 1 ]] || ([[ $# -eq 2 ]] && [[ $2 = -* ]]); then
        runasroot apt autoremove $2
      else
        runasroot apt remove "${@:2}"
        return $?
      fi
      ;;
    pg|pu|pr|purge)
      if [[ $# -eq 1 ]] || ([[ $# -eq 2 ]] && [[ $2 = -* ]]); then
        runasroot apt autopurge $2
      else
        runasroot apt purge "${@:2}"
        return $?
      fi
      ;;
    l|ls|lst|list)
      apt list ${@:2}
      return $?
      ;;
    se|search)
      apt search ${@:2}
      return $?
      ;;
    up|update)
      runasroot apt update ${@:2}
      return $?
      ;;
    upg|upgrade)
      runasroot apt upgrade ${@:2}
      return $?
      ;;
    inf|info|sh|show)
      apt show ${@:2}
      return $?
      ;;
    rei|reinstall)
      runasroot apt reinstall "${@:2}"
      return $?
      ;;
    autopurge|autopg|autopr)
      runasroot apt autopurge "${@:2}"
      return $?
      ;;
    autorm|autoremove)
      runasroot apt autoremove "${@:2}"
      return $?
      ;;
    _dyncomp)
      # 27 IQ moment:
      PATH= suapt "${@:2}" 2>/dev/null
      return 0
      ;;
    *)
      runasroot apt "$1" "${@:2}"
      return $?
      ;;
  esac
}

if [[ "$INCLUDE" = "" ]]; then
  suapt "$@"
  exit $?
fi

