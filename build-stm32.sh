#! /usr/bin/env sh

##################create stm32 project from official repository################
##################only for stm32f723e-disco this version#######################

PATH_REPO=/home/shylock/STM32Cube/Repository/STM32Cube_FW_F7_V1.11.0
PATH_BOARD=STM32F723E-Discovery
EXCLUDE="--exclude=*.chm --exclude=*.html --exclude=*.rtf --exclude=*.pdf"
PATH_TEMPLATE=/home/shylock/Workspace/config.linux/template

while getopts 'n:h' args
do
	case $args in
		n)  #!< name of project
			mkdir -p $OPTARG
			mkdir -p $OPTARG/Drivers
			# BSP
			#cp -r $PATH_REPO/Drivers/BSP/$PATH_BOARD            $OPTARG/Drivers/
			rsync -av $EXCLUDE $PATH_REPO/Drivers/BSP/$PATH_BOARD $OPTARG/Drivers/
			# CMSIS
			#cp -r $PATH_REPO/Drivers/CMSIS                      $OPTARG/Drivers/
			rsync -av $EXCLUDE --exclude=Documentation $PATH_REPO/Drivers/CMSIS $OPTARG/Drivers/
			# HAL
			#cp -r $PATH_REPO/Drivers/STM32F7xx_HAL_Driver       $OPTARG/Drivers/
			rsync -av $EXCLUDE $PATH_REPO/Drivers/STM32F7xx_HAL_Driver $OPTARG/Drivers/
			# Inc
			cp -r $PATH_REPO/Projects/$PATH_BOARD/Templates/Inc $OPTARG
			# Src
			cp -r $PATH_REPO/Projects/$PATH_BOARD/Templates/Src $OPTARG
			# middler ware
			mkdir -p $OPTARG/Middlewares
			# startup source
			cp    $PATH_REPO/Projects/$PATH_BOARD/Templates/SW4STM32/startup_stm32f723xx.s $OPTARG
			# linker script
			cp    $PATH_REPO/Projects/$PATH_BOARD/Templates/SW4STM32/STM32F723E_DISCOVERY_AXIM-FLASH/STM32F723IEKx_FLASH.ld $OPTARG
			# Makefile
			cp $PATH_TEMPLATE/cortex-m7-fpu.mk $OPTARG/Makefile
			# stlink gdb server config
			cp $PATH_TEMPLATE/stlink-gdbserver.conf $OPTARG/
			;;

		h)
			printf "usage: $0 -n <name-of-project>\n\
				eg.$0 -n example"
			;;
		?)
			echo "[err]:Unknown argument $OPTARG!"
			;;
	esac
done

shift $($OPTIND - 1)


