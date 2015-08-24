# Introduction #
  * Works well when you cron it to run once per hour.
  * If you're cron-ing as a different user, make sure that user has a ~/.cif config in their home directory
    * Also, search and replace ~root/ with ~newuser/ in this script

# Details #

```
#!/bin/sh

#
# cif_domains_to_sms.sh
#
# Loads CIF v0.01 Malicious Domain Feed Into Tippingpoint SMS Reputation Database
# v0.04 - 20120314
# Jeff Kell - Original Idea, Debug, Input
# Anthony Maszeroski - Polish and Pancakes
#

#
# SMS Instructions:
#
# a.) Log in to your SMS
# b.) On the "Profiles" tab, Select "Reputation Database" in the left-hand nav bar
# c.) Select the "Tag Categories" tab in the right-hand pane
# d.) Add the following User Defined Tag Categories
#       i.) confidence (Numeric Range)
#      ii.) description (Text)
#     iii.) impact (Text)
#      iv.) restriction (Text)
#       v.) severity (Text)
# e.) Select the SMS profile that is applied to your outbound Internet traffic
# f.) Select "Reputation" under "Infrastructure Protection"
# g.) Add an appropriate policy, e.g.:
#       i.) Filter Info : Name=CIF; Action : State=Enabled, Action Set=Block+Notify
#      ii.) Entry Criteria : DNS Domains; Tag Criteria : Include Tagged Entries, confidence="greater than or equal to 65"
# h.) Distribute the profile
#
# You'll know that it's working when you see a slew of blocked DNS query traffic involving domains in the feed 
#

#
# Temp File / Directory Info
#

OUTFILE='bt-cif-domains.csv'
TMPFILE='bt-cif-domains.txt'
WORKDIR='/tmp/cif'

#
# Location Of System Binaries
# (These Are FreeBSD Defaults)
#

AWK='/usr/bin/awk'
CAT='/bin/cat'
CIF='/usr/local/bin/cif'
CURL='/usr/local/bin/curl'
MKDIR='/bin/mkdir'
GREP='/usr/bin/grep'
GZIP='/usr/bin/gzip'
RM='/bin/rm'
SED='/usr/bin/sed'
SLEEP='/bin/sleep'
SORT='/usr/bin/sort'
WGET='/usr/local/bin/wget'

#
# Tippingpoint SMS Configuration
#

SMSSERVER='HOST.DOMAIN'

##
## SMS Throws Errors If Successive API Calls Are Made Too Quickly
##

SMSSLEEPSECS='10'

SMSID=''
SMSPW=''

if [ "${SMSID}" = "" ]; then
    SMSID=`cat ~root/.smsid`
fi

if [ "${SMSPW}" = "" ]; then
    SMSPW=`cat ~root/.smspw`
fi

#
# Create Scratch Space
#

if [ ! -d "${WORKDIR}" ]; then
   ${MKDIR} -m 0700 "${WORKDIR}" > /dev/null 2>&1
fi

#
# Fetch CIF Domain Feeds
#

${CIF} -C ~root/.cif -q domain/malware -s medium -c 65 -p csv | ${GREP} -v ^# | ${GREP} -v ^$ | awk -F, '{$4=sprintf("%d",$4 + 0.5)} {print $1",confidence,"$4",description,"$5",impact,"$8",restriction,"$14",severity,"$15}' > "${WORKDIR}/${TMPFILE}"
${CIF} -C ~root/.cif -q domain/botnet -c 65 -p csv | ${GREP} -v ^# | ${GREP} -v ^$ | awk -F, '{$4=sprintf("%d",$4 + 0.5)} {print $1",confidence,"$4",description,"$5",impact,"$8",restriction,"$14",severity,"$15}' >> "${WORKDIR}/${TMPFILE}"

#
# (Optional) - Delete All Existing User Reputation Entries
#

if [ -s "${WORKDIR}/${TMPFILE}" ]; then
    ${WGET} -q --no-check-certificate "https://${SMSSERVER}/repEntries/delete?smsuser=${SMSID}&smspass=${SMSPW}&criteria=user" -O - > /dev/null 2>&1
fi

# Sort The Feed, Deduplicate

${CAT} "${WORKDIR}/${TMPFILE}" | ${SORT} -t, -u -k1,1 | ${SORT} > "${WORKDIR}/${OUTFILE}"

#
# Load Combined Domain Lists Into The SMS
#

if [ -s "${WORKDIR}/${OUTFILE}" ]; then
    ${SLEEP} ${SMSSLEEPSECS}
    ${CURL} -s -f -k -F "file=@${WORKDIR}/${OUTFILE}" "https://${SMSSERVER}/repEntries/import?smsuser=${SMSID}&smspass=${SMSPW}&type=dns"
fi

#
# Cleanup Bits Of Pancakes And Syrup
# 

if [ -d "${WORKDIR}" ]; then
   ${RM} -rf "${WORKDIR}" > /dev/null 2>&1
fi
```