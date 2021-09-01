#!/bin/csh -f
#
# File:     WWPDBInstallSvn.csh <path>
# Updated:  17-July-2012  jdw  add additional install path for wwPDB projects
#           20-Sept-2013  jdw  remove obsoleted mmcif_pdbx_v5_internal
#            4-May-2014   jdw  add v42 dictionary
#            9-Mar-2016   jdw  adapt for SVN install
#           28-Sept-2016  ep   add v50-rc dictionary
#           28-Mar-2016   ep   Rename v50-rc xml file as v50.
#           24-Apr-2017   ep   Finish v50 naming changes.
#
# Run from top production directory only.
#
#set echo
#
if ( "x$1" == "x") then
    set installDir="../reference"
else
    set installDir=$1
endif
#
set wd = `pwd`
#
if ( -e $installDir ) then
    set targetDir = "${installDir}/dict-v4.0"
    if ( ! -e  $targetDir ) then
    	mkdir $targetDir
    endif
    #
    foreach d (mmcif_pdbx_v40 mmcif_pdbx_v41 mmcif_pdbx_v42 mmcif_pdbx_v5_next mmcif_pdbx_v50 mmcif_ddl)
	    cp mmcif/${d}.dic    ${targetDir}/${d}.dic
    	cp odb/${d}.odb      ${targetDir}/${d}.odb
    	cp sdb/${d}.sdb      ${targetDir}/${d}.sdb
    end
    #
    # ---------------------------------------------------
    #
    # Providing the V40 and V42  XML schema
    #
    cd $wd
    set schema = `cd xml_v50; ls -1 *.xsd | grep '^pdbx-v40'| grep -v '999'`
    echo "Updating $schema to pdbx-v40.xsd"
    cp xml_v50/$schema ${targetDir}/pdbx-v40.xsd
    ##
    cd $wd
    set schema = `cd xml_v50; ls -1 *.xsd | grep '^pdbx-v42'| grep -v '999'`
    echo "Linking $schema to pdbx-v42.xsd"
    cp xml_v50/$schema ${targetDir}/pdbx-v42.xsd
    # ---------------------------------------------------
    #
    # Providing the V5_rc  XML schema 
    #
    #
    cd $wd
    set schema = `cd xml_v50; ls -1 *.xsd | grep '^pdbx-v50-v5'| grep -v '999'`
    echo "Updating $schema to pdbx-v50.xsd"
    cp xml_v50/$schema ${targetDir}/pdbx-v50.xsd

    # Commit change
    cd ${targetDir}
    svn commit -m"Checkpoint dictionary and schema update"
    #
    cd $wd
endif
#
