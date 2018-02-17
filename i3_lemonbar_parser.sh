#!/bin/bash
#
# Input parser for i3 bar
# 14 ago 2015 - Electro7

# config
. $(dirname $0)/i3_lemonbar_config

# min init
title="%{F${color_head} B${color_sec_b2}}${sep_right}%{F${color_head} B${color_sec_b2}%{T2} ${icon_prog} %{F${color_sec_b2} B-}${sep_right}%{F- B- T1}"

# parser
while read -r line ; do
  case $line in
    SYS*)
      # conky=, 0 = wday, 1 = mday, 2 = month, 3 = time, 4 = cpu, 5 = mem, 6 = disk /, 7 = disk /home, 8-9 = up/down wlan, 10-11 = up/down eth, 12-13=speed 14=bat
      sys_arr=(${line#???})
      # date
      if [ ${res_w} -gt 1024 ]; then
        date="${sys_arr[0]} ${sys_arr[1]} ${sys_arr[2]}"
      else
        date="${sys_arr[1]} ${sys_arr[2]}"
      fi
      date="%{F${color_wsp}}${sep_left}%{F${color_back} B${color_wsp}} %{T2}${icon_cal}%{F- T1}%{F${color_back}} ${date}"
      # time
      time="%{F${color_head}}${sep_left}%{F${color_back} B${color_head}} %{T2}${icon_clock}%{F- T1}%{F${color_back}} ${sys_arr[3]} %{F- B-}"
      # cpu
      if [ ${sys_arr[4]} -gt ${cpu_alert} ]; then
        cpu_cback=${color_cpu}; cpu_cicon=${color_back}; cpu_cfore=${color_back};
      else
        cpu_cback=${color_sec_b2}; cpu_cicon=${color_icon}; cpu_cfore=${color_fore};
      fi
      cpu="%{F${cpu_cback}}${sep_left}%{F${cpu_cicon} B${cpu_cback}} %{T2}${icon_cpu}%{F${cpu_cfore} T1} ${sys_arr[4]}%"
      # mem
      mem="%{F${cpu_cicon}}${sep_l_left} %{T2}${icon_mem}%{F${cpu_cfore} T1} ${sys_arr[5]}"
      # disk /
      diskr="%{F${color_sec_b1}}${sep_left}%{F${color_icon} B${color_sec_b1}} %{T2}${icon_hd} %{F- T1}${sys_arr[6]}%"
      # ethernet
      eth_cback=${color_sec_b1}; eth_cfore=${color_fore};
      if [ "${sys_arr[7]}" == "down" ]; then
        ethup=""; eth_cicon=${color_fore};
      else
        ethup=${icon_ethernet}; eth_cicon=${color_icon};
      fi
      ethernet="%{F${eth_cback}}${sep_left}%{F${eth_cicon} B${eth_cback}} %{T2}%{F${eth_cicon} T1}${ethup}";
      # wlan
      wlan_cback=${color_sec_b1}; wlan_cfore=${color_fore};
      if [ "${sys_arr[8]}" == "down" ]; then
        wlanup=""; wlan_cicon=${color_fore};
      else
        wlanup=${icon_wifi}; wlan_cicon=${color_icon};
      fi
      wifi="%{F${wlan_cback}}${sep_left}%{F${wlan_cicon} B${wlan_cback}} %{T2}%{F${wlan_cicon} T1}${wlanup}";
      # tether
      teth_cback=${color_sec_b1}; teth_cicon=${color_icon}; teth_cfore=${color_fore};
      if [ "${sys_arr[9]}" == "down" ]; then
        tethup=""; teth_cicon=${color_fore};
      else
        tethup=${icon_tether}; teth_cicon=${color_icon};
      fi;
      tether="%{F${teth_cback}}${sep_left}%{F${teth_cicon} B${teth_cback}} %{T2}%{F${teth_cicon} T1}${tethup}";
      # bat
      if [ "${sys_arr[11]}" == "D" ]; then
        icon_bat="";
      else
        icon_bat="";
      fi
      if [ ${sys_arr[10]} -lt ${bat_alert} ]; then
        bat_cback=${color_cpu}; bat_cicon=${color_back}; bat_cfore=${color_back};
      else
        bat_cback=${color_sec_b2}; bat_cicon=${color_icon}; bat_cfore=${color_fore};
      fi
      bat="%{F${bat_cback}}${sep_left}%{B${bat_cback}}%{F${bat_cfore}}%{T2}%{F${bat_cicon}%{F${bat_cfore} T1} ${icon_bat} ${sys_arr[10]}%"
      ;;
    VOL*)
      # Volume
      vol="%{F${color_sec_b2}}${sep_left}%{F${color_icon} B${color_sec_b2}} %{T2}${icon_vol}%{F- T1} ${line#???}"
      ;;
    GMA*)
      # Gmail
      gmail="${line#???}"
      if [ "${gmail}" != "0" ]; then
        mail_cback=${color_mail}; mail_cicon=${color_back}; mail_cfore=${color_back}
      else
        mail_cback=${color_sec_b1}; mail_cicon=${color_icon}; mail_cfore=${color_fore}
      fi
      gmail="%{F${mail_cback}}${sep_left}%{F${mail_cicon} B${mail_cback}} %{T2}${icon_mail}%{F${mail_cfore} T1} ${gmail}"
      ;;
    WSP*)
      # I3 Workspaces
      wsp="%{F${color_back} B${color_head}} %{T2}${icon_wsp}%{T1}"
      set -- ${line#???}
      while [ $# -gt 0 ] ; do
        case $1 in
         FOC*)
           wsp="${wsp}%{F${color_head} B${color_wsp}}${sep_right}%{F${color_back} B${color_wsp} T1} ${1#???} %{F${color_wsp} B${color_head}}${sep_right}"
           ;;
         INA*|URG*|ACT*)
           wsp="${wsp}%{F${color_disable} T1} ${1#???} "
           ;;
        esac
        shift
      done
      ;;
    WIN*)
      # window title
      title=$(xprop -id ${line#???} | awk '/_NET_WM_NAME/{$1=$2="";print}' | cut -d'"' -f2)
      #title="%{F${color_head} B${color_sec_b2}}${sep_right}%{F${color_head} B${color_sec_b2}%{T2} ${icon_prog} %{F${color_sec_b2} B-}${sep_right}%{F- B- T1} ${title}"
      title="%{F${color_head} B${color_sec_b2}}${sep_right}%{F${color_icon} B${color_sec_b2} T2} ${icon_prog} %{F${color_sec_b2} B-}%{F- B- T1}%{F${color_sec_b2}}${sep_right}%{F${color_icon}} ${title}"
      ;;
  esac

  # And finally, output
  printf "%s\n" "%{l}${wsp}${title} %{r}${gmail}${stab}${cpu}${stab}${mem}${stab}${diskr}${stab}${vol}${stab}${ethernet}${wifi}${tether}${stab}${bat}${stab}${date}${stab}${time}"
  #printf "%s\n" "%{l}${wsp}${title}"
done
