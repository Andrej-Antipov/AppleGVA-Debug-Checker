#!/bin/sh

# FUNCS

DISPLAY_NOTIFICATION(){
~/Library/Application\ Support/AppleGVADetector/$vendor/terminal-notifier.app/Contents/MacOS/terminal-notifier -title "${TITLE}" -subtitle "${SUBTITLE}" -message "${MESSAGE}" 
}

MESSAGE_HARDWARE(){
        if [[ $loc = "ru" ]]; then
        TITLE="Декодер: ""$decoder"
        SUBTITLE="Клиент: ""$client"
        MESSAGE="АППАРАТНОЕ ДЕКОДИРОВАНИЕ"
        DISPLAY_NOTIFICATION &
        else
        TITLE="Декодер ""$decoder"
        SUBTITLE="Client: ""$client"
        MESSAGE="HARDWARE VIDEO DECODING"
        DISPLAY_NOTIFICATION &
        fi

}

MESSAGE_SOFTWARE(){
        if [[ $loc = "ru" ]]; then
        TITLE="Декодер: ""$decoder"
        SUBTITLE="Клиент ""$client"
        MESSAGE="ВИДЕО ДЕКОДИРУЕТСЯ ПРОГРАММНО"
        DISPLAY_NOTIFICATION &
        else
        TITLE="Декодер: ""$decoder"
        SUBTITLE="$client"
        MESSAGE="SOFTWARE VIDEO DECODING"
        DISPLAY_NOTIFICATION &
        fi
        sleep 0.5
     
}

MESSAGE_ERROR(){
    
        if [[ $loc = "ru" ]]; then
        TITLE="Декодер: ""$decoder"
        SUBTITLE="Клиент ""$client"
        MESSAGE="ОШИБКА! ПЕРЕХОД НА ПРОГРАММНЫЙ ДЕКОДEP"
        DISPLAY_NOTIFICATION &
        else
        TITLE="Декодер: ""$decoder"
        SUBTITLE="$client"
        MESSAGE="ERROR! PASS TO SOFTWARE DECODER"
        DISPLAY_NOTIFICATION &
        fi
        sleep 0.5
}

# INIT
gva_debug=$( defaults read com.apple.AppleGVA enableSyslog 2>/dev/null )
if [[ ! $gva_debug = 1 ]]; then defaults write com.apple.AppleGVA enableSyslog -boolean true ; fi

loc=`defaults read -g AppleLocale | cut -d "_" -f1`; if [[ ! $loc = "ru" ]]; then loc="en"; fi

# MAIN
    
  while true
do 

unset a
res=$( log stream --style compact --predicate 'eventMessage CONTAINS "GVA"' | egrep -b7 -m 1 "PhysicalAccelerator create error" )
a=$( echo "$res" | grep -m 1 "PhysicalAccelerator create error" | awk '{print $NF}' )
client=$( echo "$res" | grep -m 1 "plugin is" | cut -f1 -d '[' | cut -f3 -d: | cut -c 11- ); if [[ ${#client} -gt 41 ]]; then client=$( echo "${client:0:41}" ); fi
error=""; error=$(echo "$res" | grep -o "GVA error:" )

    vendor=""
    vendor=$( echo "$res" | grep -m 1 "plugin is" | grep -o ATI ); 
    if [[ $vendor = "" ]]; then vendor=$( echo "$res" | grep -m 1 "plugin is" | grep -o INTEL ); fi
    if [[ $vendor = "" ]]; then vendor=$( echo "$res" | grep -m 1 "plugin is" | grep -o NVIDIA ); fi
    if [[ $vendor = "INTEL" ]] || [[ $vendor = "NVIDIA" ]]; then decoder=$( echo "$res" | grep -m 1 "plugin is" |  cut -f5 -d: | cut -c 12- | tr -d ",." ); fi
    if [[ $vendor = "ATI" ]]; then decoder="ATI"; fi
  
if [[ ! "$error" = "" ]] && [[ $a -lt 0 ]]; then MESSAGE_ERROR; elif [[ $a -lt 0 ]]; then MESSAGE_SOFTWARE; elif [[ $a = 0 ]]; then MESSAGE_HARDWARE; fi
done

