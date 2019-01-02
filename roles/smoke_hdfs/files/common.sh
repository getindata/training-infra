#!/bin/bash

function check_error_code {
               if [ `echo $?` -eq 0 ]; then
   			echo OK
      		   else
   			echo FAIL
   			exit 1
		fi 
           }
