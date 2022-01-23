#!/bin/bash
/usr/bin/spotify start &
window_id=wmctrl | grep -i spotify | awk '{print $1}'
echo $window_id
#chmod u+x test.sh
