#!/bin/bash

unset has
unset suapt
unset suapt-pm
unset suapt-su
unset suapt-cfg

has() {
  which $@ 2> /dev/null > /dev/null
  return $?
}

suapt-cfg() {
  local cfg="$HOME/.suapt_config"
  
  case "$1" in
    read)
      test -e "$cfg" || return 0
      while read ln; do
        case "$ln" in
          in_termux=true)
            echo 'local termux=true'
            ;;
          pm=*)
            echo 'local pm="'"$(echo "${ln#pm=}" | sed 's/"//g')\""
            ;;
          use_apk=true)
            echo 'local xmod=true'
            echo 'local pm="apk"'
            echo 'export install=add'
            echo 'export remove=del'
            echo 'export purge="--purge del"'
            echo 'export autoremove="cache clean"'
            echo 'export autopurge="--purge cache clean"'
            echo 'export fix=fix'
            echo 'export _FAKE_REINSTALL=true'
            ;;
          use_apk=false|'#'*)
            ;;
          *)
            #printf "Unknown syntax in %s:\n | %s\n" "$cfg" "$ln" > /dev/stderr
            ;;
        esac
      done < "$cfg"
      ;;
    set)
      echo "$2=$3" >> "$cfg"
      ;;
    unset)
      sed -i 's/^\('"$(echo $2 | sed 's/\///g')"')/#\1/' "$cfg"
      ;;
  esac
}

# suapt-su $@
# example: suapt-su cat /etc/shadow
suapt-su() {
  local args="$@"
  has sustorage && local sus=1 || local sus=0
  has doas      && local das=1 || local das=0
  has sudo      && local sdo=1 || local sdo=0
  has su        && local su=1  || local su=0
  if [[ $sus -ne 0 ]]; then
    sustorage prompt root "$@"
  elif [[ $das -ne 0 ]]; then
    doas -u root "$@"
  elif [[ $sdo -ne 0 ]]; then
    sudo "$@"
  elif [[ $su -ne 0 ]]; then
    su -c "$args"
  else
    echo -e "\e[31mFATAL:\e[0m no provider found for suapt-su\n" \
      "  Check suapt -su or suapt -version (suapt-su fallback providers)" > /dev/stderr
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

# _PMPATH=apt
# _SUPATH=suapt-su
# suapt-pm $action $@
suapt-pm() {
  [[ "${_PMPATH}" = "" ]] \
    && local pm=apt \
    || local pm="${_PMPATH}"
  [[ "${_SUPATH}" = "" ]] \
    && local su=suapt-su \
    || local su="${_SUPATH}"

  [[ "${install}" = "" ]] \
    && local install=install
  [[ "${remove}" = "" ]] \
    && local remove=remove
  [[ "${purge}" = "" ]] \
    && local purge=purge
  [[ "${autoremove}" = "" ]] \
    && local autoremove=autoremove
  [[ "${autopurge}" = "" ]] \
    && local autopurge=autopurge
  [[ "${fix}" = "" ]] \
    && local fix="install -f"

  case "$1" in
    install)
      $su $pm $install "${@:2}"
      ;;
    uninstall)
      $su $pm $remove "${@:2}"
      ;;
    reinstall)
      if [[ "${_FAKE_REINSTALL}" -eq "true" ]]; then
        $su $pm $remove "${@:2}" && $su $pm $install "${@:2}"
      else
        $su $pm reinstall "${@:2}"
      fi
      ;;
    hard-uninstall)
      $su $pm $purge "${@:2}"
      ;;
    clean)
      $su $pm $autoremove "${@:2}"
      ;;
    hard-clean)
      $su $pm $autopurge "${@:2}"
      ;;
    list)
      $pm list "${@:2}"
      ;;
    advanced-list)
      $pm search "${@:2}"
      ;;
    info)
      $pm show "${@:2}"
      ;;
    repo-update)
      $su $pm update "${@:2}"
      ;;
    sys-update)
      $su $pm upgrade "${@:2}"
      ;;

    fix)
      $su $pm $fix "${@:2}"
      ;;

    version|creds)
      local pmv="$($pm --version 2>/dev/null)"
      [[ "$pmv" = "" ]] \
        && echo "\e[31m$pm not installed\e[0m" \
        || echo "${pmv}"
      ;;
  esac

  return $?
}

suapt() {
  local pm=apt
  if [[ "$PATH" = "" ]]; then
    export _PMPATH="echo $pm"
    export _SUPATH=" "
  else
    eval "$(suapt-cfg read)"

    export _PMPATH="$pm"
    [[ "$termux" = true ]] \
      && export _SUPATH=" " \
      || export _SUPATH=suapt-su
  fi

  if [[ "$1" = "-version" ]] || [[ "$1" = "-V" ]]; then
    local notav="\e[1;31m"
    local nc="\e[0m"
    local ok=""
    local b="\e[1m"

    local ctc="\e[0;34m"
    [[ "$IDIOT_MODE" = "1" ]] \
      && local cbc="\e[0;33m" \
      || local cbc="$ctc"

    local sustorage=$(sustorage revision 2>/dev/null)
    has su        && local sup=$ok   || local sup=$notav
    has doas      && local doasp=$ok || local doasp=$notav
    has sudo      && local sudop=$ok || local sudop=$notav
    has sustorage && local susp=$ok  || local susp=$notav
    [[ $sustorage = "" ]] && sustorage="none"
    [[ "$xmod" = true ]] \
      && echo    "suapt -- like su -c 'apk...', without sudo" \
      || echo    "suapt -- like su -c 'apt...', without sudo"
    echo -e "  version:    \e[1m0.10.1\e[0m"
    echo -e "  sustorage:  \e[1m$sustorage\e[0m"
    echo -e "  suapt-pm:   \e[1m$(suapt-pm creds)\e[0m"
    echo -e "  suapt-su:  $susp sustorage$nc$doasp doas$nc$sudop sudo$nc$sup su$nc"
    echo -e "   -- More info about suapt-su:$b suapt -su$nc"
    echo    "   -- Note: suapt is just user aliases, not fully util"
    echo
    echo -e "src: Amchik/suapt    $ctc __   __   \e[0m"
    echo -e "                $ctc ____/ /  / /__ \e[0m"
    echo -e "Made by ${ctc}Amc${cbc}hik  $cbc/ __/ _ \\/  '_/ \e[0m"
    echo -e "     with \e[35mlove  $cbc\\__/_//_/_/\\_\\  \e[0m"
    [[ "$xmod" = true ]] \
      && echo -e " This \e[1;35mapx\e[0m has \e[0;33msandwich\e[0m making abilities." \
      || [[ "$termux" = true ]] \
        && echo -e " This \e[1;35msuapt\e[0m has \e[0;36mbiscuits\e[0m making abilities." \
        || echo -e " This \e[1;35msuapt\e[0m has \e[0;32mtea\e[0m making abilities."
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
        echo "  Please recheck installed packages via suapt l -i"
        echo "  or fix \$PATH. Default \$PATH are" 
        echo "  '/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin'."
        echo "For su (/bin/su, /usr/bin/su) install util-linux package"
      fi
      ;;
    i|in|ins|inst|insta|instal|install|add|require)
			suapt-pm install "${@:2}"
      ;;
    rm|rem|remove|de|dd|del|dele|delet|delete)
      if [[ $# -eq 1 ]] || ([[ $# -eq 2 ]] && [[ $2 = -* ]]); then
        suapt-pm clean $2
      else
        suapt-pm uninstall "${@:2}"
      fi
      ;;
    gg|pg|pu|pr|purge)
      if [[ $# -eq 1 ]] || ([[ $# -eq 2 ]] && [[ $2 = -* ]]); then
        suapt-pm hard-clean $2
      else
        suapt-pm hard-uninstall "${@:2}"
      fi
      ;;
    -f|fix|fx|f)
      suapt-pm fix "${@:2}"
      ;;
    l|ls|lst|lts|list|lits)
      suapt-pm list ${@:2}
      ;;
    s|sl|ss|se|search)
      suapt-pm advanced-list ${@:2}
      ;;
    sync|sycn|up|update)
      suapt-pm repo-update ${@:2}
      ;;
    upg|upgrade)
      suapt-pm sys-update ${@:2}
      ;;
    inf|info|sh|show|about|a)
      suapt-pm info ${@:2}
      ;;
    rr|rei|reinstall)
      suapt-pm reinstall "${@:2}"
      ;;
    autopurge|autopg|autopr|autogg|autopu)
      suapt-pm hard-clean "${@:2}"
      ;;
    rm|autorem|autoremove|autode|autodd|autodel|autodele|autodelet|autodelete)
      suapt-pm clean "${@:2}"
      ;;
    _dyncomp)
      # 27 IQ moment:
      PATH= suapt "${@:2}"
      return 0
      ;;
    do)
      suapt-su $pm "$2" "${@:3}"
      ;;
    sdo)
      $pm "$2" "${@:3}"
      ;;
    *)
      suapt install "$@"
      ;;
  esac

  return $?
}

if [[ "$INCLUDE" = "" ]]; then
  suapt "$@"
  exit $?
fi

