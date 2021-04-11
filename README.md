![whois.sh](whois.png)

`whois.sh` is a useless, unusable, incomplete, badly coded and poorly designed 
bash rewrite of the standard Linux whois command.

Sometime is fun to fix something that is not broken replacing it with something
else which is broken by design.

This client is dumb and just in some cases can automatically select a kinda ok
whois server for the given query.
In every other cases you need to query the specific whois server to get the infos.

## Querying a whois server
If you really whant to do so, you can query a specific whois server:

```
./whois.sh --host whois.nic.dev --port 43 google.dev
```

## Whois an IP address
`whois.sh` is dumb and can't autoguess the correct whois server for a given IP.
But, again, you can directly send a query to a whois server:

```
./whois.sh --host whois.arin.net 140.82.121.3
```

## That's all
Feel free to be upset about the existence of this dumb whois client.
