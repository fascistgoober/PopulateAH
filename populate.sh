#!/bin/sh

# Oh hi.
DEBUG=0

# Reset insert.sql
echo "" > insert.sql

# databases + tables
## TODO: Create both for horde-side and alliance-side
AUCTIONEER_ID=0 # (If you want a specific name.) #NOTE: mine is 5.
ITEM_DB="acore_world"
ITEM_TBL="item_template"
AH_DB="acore_characters"
AH_TBL="auctionhouse"
II_TBL="item_instance" # Belongs with AH_DB.

# MAGIC_NUMBER = 129600 seconds (72 hours) -- May not need.
ADD_TIME="129600"
EPOCH=`date -d '+48 hours' +%s`
FINAL_TIME=$EPOCH
#FINAL_TIME=`expr ${EPOCH} + ${ADD_TIME}`
FIND_AH_MAX_ENTRY=`mysql -e "SELECT MAX(ID) FROM ${AH_DB}.${AH_TBL};"`
AH_MAX_ENTRY="`echo ${FIND_AH_MAX_ENTRY} | sed 's/.*) //'`"

# mysql -e "SELECT MAX(GUID) FROM acore_characters.item_instance;"
FIND_II_MAX_ENTRY=`mysql -e "SELECT MAX(GUID) FROM ${AH_DB}.${II_TBL};"`
II_MAX_ENTRY="`echo ${FIND_II_MAX_ENTRY} | sed 's/.*) //'`"


# Item list (Currently only BoE containers)
## TODO: Modify to pull from init.config, and allow for multiple conditionals!
ITEMS_LIST=`mysql -e "select entry,BuyPrice,SellPrice FROM ${ITEM_DB}.${ITEM_TBL} WHERE class = 1 AND Quality < 3 AND (bonding = 2);"`

# Prepare formatting for list.tmp
echo "`echo ${ITEMS_LIST} | tr " " "," | xargs --delimiter="," -n3 | sed 1d | head -n -1 | sed 's/ /,/g' > list.tmp `"

##
# Create the auctionhouse entries
# and item_template entries.
##

while read line;
do
 AH_MAX_ENTRY=`expr ${AH_MAX_ENTRY} + 1`
 II_MAX_ENTRY=`expr ${II_MAX_ENTRY} + 1`
 if [ $DEBUG -eq 1 ]
 then
   ##
   # item_template entry.
   ##
   TMP_ITEM_ID=`echo $line | sed "s/,.*//"`
   DETAIL=`mysql -e "select name FROM acore_world.item_template WHERE entry = ${TMP_ITEM_ID};"`
   DETAIL=`echo $DETAIL | sed "s/name /[/" | sed "s/$/]/"` 
   echo "$DETAIL"
   echo `echo "-- [$DETAIL]"` >> insert.sql
   ##
   # auctionhouse entry.
   ##
   echo "ITERATION ${AH_MAX_ENTRY}";
   echo "ADDED: " $line | sed "s/^/INSERT INTO ${AH_DB}.${AH_TBL} (id, houseid, itemowner, itemguid, buyoutprice, startbid, time) VALUES (${AH_MAX_ENTRY},7,${AUCTIONEER_ID},/" | sed "s/$/);/";
   # `Characters.item_instance:enchantments` does not have a default value.
   ENCHANTMENTS="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"
   echo $line | sed "s/,.*//" | sed "s/^/INSERT INTO ${AH_DB}.${II_TBL} (guid, itemEntry, enchantments) VALUES (${II_MAX_ENTRY},/" | sed "s/$/,\"${ENCHANTMENTS}\");/"
   echo ""
 fi
 echo $line | sed "s/,.*//" | sed "s/^/INSERT INTO ${AH_DB}.${II_TBL} (guid, itemEntry, enchantments) VALUES (${II_MAX_ENTRY},/" | sed "s/$/,\"${ENCHANTMENTS}\");/" >> insert.sql
 echo $line | sed "s/[0-9]*,/${II_MAX_ENTRY},/" | sed "s/^/INSERT INTO ${AH_DB}.${AH_TBL} (id, houseid, itemowner, itemguid, buyoutprice, startbid, time) VALUES (${AH_MAX_ENTRY},7,${AUCTIONEER_ID},/" | sed "s/$/,${FINAL_TIME});/" >> insert.sql
done < list.tmp


if [ $DEBUG -eq 1 ]
then
 echo "mysql < insert.sql"
 echo "ALERT: This was not ran."
else
 $(mysql < insert.sql)
fi

# Gets rid of the list.
if [ $DEBUG -eq 0 ]
then
 $(rm list.tmp)
 $(rm insert.sql)
else
 echo "list.tmp was kept for review."
 echo "insert.sql was kept for review."
fi

echo "Finished."
