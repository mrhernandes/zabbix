	#!/bin/bash
	### Verificando conectividade com a Internet

	# set -x

	export site1="uol.com.br"
	export site2="google.com"
	export site3="terra.com.br"

	wget $site1 -nv -o /dev/null
		if [ $? == 0 ]
			then echo "Internet OK - $site1 verificado com sucesso!"
			else wget $site2 -nv -o /dev/null 
				 if [ $? == 0 ]
						then echo "Internet OK - $site2 verificado com sucesso!"
							else wget $site3 -nv -o /dev/null
						if [ $? == 0 ]
							then echo "Internet OK - $site3 verificado com sucesso!"
							else echo "Internet ERROR"
						fi
				fi
		fi
	exit 0
