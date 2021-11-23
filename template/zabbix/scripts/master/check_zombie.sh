pdsh -g nodes "ps axo pid=,stat=,user= | grep Z" 2> /dev/null
pdsh -g login "ps axo pid=,stat=,user= | grep Z" 2> /dev/null
pdsh -g viz "ps axo pid=,stat=,user= | grep Z" 2> /dev/null
