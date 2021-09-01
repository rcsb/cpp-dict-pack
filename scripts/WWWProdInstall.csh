#!/bin/csh -f
#
# File:    WWWProdInstall.csh
# Updates: 23-Nov-2013  JDW Copy dictionary and schema files to PDBx/mmCIF website download directories.
#          21-Apr-2014  JDW add pdbx-v42 schema support
#          29-Mar-2017  EP  Handle v5_rc dictionary v50 pdbml schema
#
#          DOCS_ONTOLOGIES_TOP  -
#                 PDBX_INSTALL_TOP_PATH  = "$DOCS_ONTOLOGIES_TOP/mmcif"
#                 PDBML_INSTALL_TOP_PATH = "$DOCS_ONTOLOGIES_TOP/pdbml"
# ---
#         Script must be run from the directory containing the main make file!
#                (eg. ./bin/WWWProdInstall.csh)
#set echo
set rdir = `pwd`
#
if ( ! $?DOCS_ONTOLOGIES_TOP)  then
    echo "Path to website download directory PDBX_INSTALL_PATH not set -using default"
    set PDBX_INSTALL_TOP_PATH = "/net/www-rcsb/ontologies-prod/docs-ontologies/mmcif"
    set PDBML_INSTALL_TOP_PATH = "/net/www-rcsb/ontologies-prod/docs-ontologies/pdbml"
else
    set PDBX_INSTALL_TOP_PATH  = "$DOCS_ONTOLOGIES_TOP"
    set PDBML_INSTALL_TOP_PATH = "$DOCS_ONTOLOGIES_TOP"
endif


if (! -e $PDBX_INSTALL_TOP_PATH/dictionaries ) then
    mkdir -p $PDBX_INSTALL_TOP_PATH/dictionaries
endif

if (! -e $PDBML_INSTALL_TOP_PATH/schema ) then
    mkdir -p $PDBML_INSTALL_TOP_PATH/schema
endif

#
set dicts = " mmcif_pdbx_v5_next mmcif_pdbx_v50 mmcif_pdbx_v40 mmcif_pdbx_v32 mmcif_pdbx_v31 mmcif_nmr-star  mmcif_biosync mmcif_ccp4  mmcif_ddl mmcif_img mmcif_sas mmcif_nef mmcif_ma mmcif_rcsb_nmr mmcif_rcsb_xray mmcif_std mmcif_sym mmcif_em mmcif_ihm mmcif_ndb_ntc mmcif_pdbx_vrpt"
#
#
# pdbx-v50 handled below
# Leave out mmcif_ihm, mmcif_ndb_ntc and mmcif_ma for now
set schemaNames="pdbx-v50-next pdbx-v42 pdbx-v40 pdbx-v32 mmcif_biosync mmcif_ccp4 mmcif_ddl  mmcif_em  mmcif_img  mmcif_sas mmcif_nef mmcif_ma mmcif_nmr-star mmcif_std mmcif_sym"
#
foreach d ($dicts)
    cat dicts/dict-$d/$d'.dic' | gzip >  $PDBX_INSTALL_TOP_PATH/dictionaries/$d'.dic.gz'
    cp  dicts/dict-$d/$d'.dic' $PDBX_INSTALL_TOP_PATH/dictionaries/
    echo "Updating dictionary $d"
end
#
cd xml_v50
set schema4 = `ls -1 *.xsd | grep '^pdbx-v40' | grep -v '999'`
cp $schema4 $PDBML_INSTALL_TOP_PATH/schema/
#
set schema42 = `ls -1 *.xsd | grep '^pdbx-v42' | grep -v '999'`
cp $schema42 $PDBML_INSTALL_TOP_PATH/schema/
#
set schema5next = `ls -1 *.xsd | grep '^pdbx-v50-next' | head -1`
cp $schema5next $PDBML_INSTALL_TOP_PATH/schema/
#
set schema5 = `ls -1 *.xsd | grep '^pdbx-v50-v' | head -1`
cp $schema5 $PDBML_INSTALL_TOP_PATH/schema/
cd ..


##
cd $PDBX_INSTALL_TOP_PATH/schema/
rm -f pdbx-v40.xsd
ln -s $schema4 pdbx-v40.xsd

rm -f pdbx-v42.xsd
ln -s $schema4 pdbx-v42.xsd

rm -f pdbx-v50.xsd
ln -s $schema5 pdbx-v50.xsd

rm -f pdbx-v50-next.xsd
ln -s $schema5next pdbx-v50-next.xsd
#
##
##
#set echo
foreach d ($schemaNames)
  cd $rdir/xml_v50
  set schema = `ls -1 *.xsd | grep $d | grep -v '999' | head -1 `
  if ( "x$schema" != "x") then
      if ( -e $schema) then
    	cp $schema $PDBML_INSTALL_TOP_PATH/schema/
    	cd $PDBML_INSTALL_TOP_PATH/schema
    	rm -f $d.xsd
    	ln -s $schema $d.xsd
    	echo "Updating schema $d"
    endif
  endif
end
##
cd $PDBML_INSTALL_TOP_PATH/schema
rm -f pdbx-v50.xsd
ln -s $schema5 pdbx-v50.xsd

##
##



