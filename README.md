# PopulateAH

This script generates an SQL file to populate your auction house.

In theory, I'd handpick the items, but I'm also a little lazy.

In its current condition, the items are placed up to last for
48 hours, the buy out is set to BuyPrice, the bid is set to SellPrice.

Unfortunately, you have to restart the server. Its just something I tried
and it worked. There may be a better way, I'll try to find one... (For example,
maybe theres a command to load only the auctions in `worldserver` -- I'd imagine
there is. I'll look later. If not, its a feature I'll try to make.) 


# Usage

Its written in shell for now. That means it only works on Linux/BSD I guess.

```
$ sh populate.sh
$ # Restart the server
```

# TODO
```
[ ] Add in every item
[ ] Create whitelist
[ ] Create blacklist
[ ] Add in switch for the whitelist/blacklists
[ ] Come up with a better pricing solution. 
[ ] Find a way to not have to reboot the server
[ ] refactor
[ ] Windows support
```

# Version 0.0.1

This is just a test to make it work that only puts up BoE containers.
I can scale this up from here.

It only adds one of each item at the moment. I should probably include n amounts
based on quality, or just randomize it completely.


Note: I noticed when I include "bonding=0", I get some items that need
to be black listed. This is why it is only BoE items for now.

