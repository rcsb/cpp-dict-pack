# CifCheck Program Documentation

## Overview
Additions to the CifCheck program include the inclusion of secondary keys, categories that can be treated as mandatory based on the value of a target item, and items that can be treated as mandatory based on the value of a target item.

## Changes to CifCheck

### New Additions
1. New Files
- CifConditionalContext.h and CifConditionalContext.C

2. New Functions
- CifConditionalContext.C
    - RequireTable
        - Determine if category should be treated as mandatory based on condition
    - RequireItem
        - Determine if item should be treated as mandatory based on condition
- CifFile.C
    - CheckCategorySecondaryKey
        - Checks the category secondary key table for key_id and item_name items
    - GetSecondaryKeyAttributes
        - Determine values of key_id and item_name items
    - CheckSecondaryKeyItems
        - Check for existence of key_id and item_name values and, if they exist, checks if there are duplicate key values
    - CheckSecondaryKeyValues
        - Determine if key_id and item_name values are set to inapplicable
    - FixInapplicableValues
        - Change key_id and item_name values from inapplicable to unknown
    - CheckConditionalCategories
        - Determine if category should be treated as mandatory based on condition and, if so, enforce it
    - CheckConditionalItems
        - Determine if item should be treated as mandatory based on condition and, if so, enforce it

### Modifications
- CifFile.C
    - DataChecking
        - Includes checks for secondary keys, conditional mandatory categories, and conditional mandatory items
    - CheckCategories
        - Includes checks for conditional mandatory categories
    - CheckItems
        - Includes checks for secondary keys and conditional mandatory items


## CifCheck Command Line Arguments
- ```-ec_pdbx```
    - (optional) Extra Cif checks

- ```-f <CIF file>``` or ```-l <CIF files list>```
    - Option 1 (-f):
        - Single Cif file to check
    - Option 2 (-l):
        - List of Cif files to check

- ```-dictSdb <dictionary SDB file>``` or ```-dict <dictionary ASCII file> -ddl <DDL ASCII file>```
    - Option 1 (-dictSdb):
        -  Single .sdb file containing MMCIF/PDBx dictionary information (Output of the DictToSdb program)
    - Option 2 (needs -dict AND -ddl flags):
        - (-dict): Single .dic file containing MMCIF/PDBx dictionary information
        - (-ddl): Single .dic file containing DDL2 information

- ```-checkFirstBlock```
    - (optional) Only check first block of Cif file

- ```-disableSecKeyChecks```
    - (optional) Disable secondary key checks

- ```-disableCondMandatoryCatChecks```
    - (optional) Disable conditional mandatory category checks

- ```-disableCondMandatoryItemChecks```
    - (optional) Disable conditional mandatory item checks

## Usage
Using human deoxyhemoglobin (PDB ID 4hhb) as the Cif file and mmcif_pdbx_v5_next.sdb as the reference dictionary as an example, the enabling and disabling of different checks can be performed based on the needs of the user.

1. Execute CifCheck at its most basic level (no secondary keys or conditional mandatory elements) </br>
```
../bin/CifCheck -f 4hhb.cif -dictSdb mmcif_pdbx_v5_next.sdb -disableSecKeyChecks -disableCondMandatoryCatChecks -disableCondMandatoryItemChecks
```

2. Execute CifCheck with secondary key checking only </br>
```
../bin/CifCheck -f 4hhb.cif -dictSdb mmcif_pdbx_v5_next.sdb -disableCondMandatoryCatChecks -disableCondMandatoryItemChecks
```

3. Execute CifCheck with conditional mandatory categories only </br>
```
../bin/CifCheck -f 4hhb.cif -dictSdb mmcif_pdbx_v5_next.sdb -disableSecKeyChecks -disableCondMandatoryItemChecks
```

4. Execute CifCheck with conditional mandatory items only </br>
```
../bin/CifCheck -f 4hhb.cif -dictSdb mmcif_pdbx_v5_next.sdb -disableSecKeyChecks -disableCondMandatoryCatChecks
```

5. Execute CifCheck with both conditional mandatory categories and items </br>
```
../bin/CifCheck -f 4hhb.cif -dictSdb mmcif_pdbx_v5_next.sdb -disableSecKeyChecks
```

6. Execute CifCheck with both conditional mandatory categories and items as well as secondary key checking </br>
```
../bin/CifCheck -f 4hhb.cif -dictSdb mmcif_pdbx_v5_next.sdb
```