#!/usr/bin/env python

# Small script to extract the version number of a dictionary at configuration time
# This is not a cif parser - just a quick and dirty approach
import argparse
import os
import sys
import re

from DictConfig import DictConfig


class DictVersion(object):
    def __init__(self, dict_file):
        self.__pathin = dict_file

    def getVersion(self):
        with open(self.__pathin, "r") as fin:
            dictin = fin.read().splitlines()

        verexp = re.compile("(^[ \t]*_dictionary.version[ \t]*)([a-zA-Z0-9.]*)[ \t]*$")
        for r in dictin:
            m = verexp.match(r)
            if m:
                vers = m.group(2)
                return vers
        return None

    def getXsdVersionName(self):
        """Determines the output xsd file name.  Based on Dict2XMLSchema.csh"""
        vers = self.getVersion()
        if vers is None:
            return None

        # Determine the filename
        bname = os.path.basename(self.__pathin)
        dname = bname.split(".")[0]

        dc = DictConfig()
        prefix = dc.get_prefix(dname)
        if prefix:
            vout = "%s-v%s.xsd" % (prefix, vers)
            return vout

        return None


def main():
    parser = argparse.ArgumentParser(
        description="Retrieves version number of dictionary",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument("--dict-file", type=str, required=True,
                        help="Path to dictionary")
    parser.add_argument('--print-xsdname', action='store_true',
                        help='Prints the XSD name')

    args = parser.parse_args()
    # sys.stderr.write("%s\n" % args)

    dv = DictVersion(args.dict_file)

    if args.print_xsdname:
        vers = dv.getXsdVersionName()
        if vers:
            sys.stdout.write(vers)
            return 0
    else:
        vers = dv.getVersion()
        if vers:
            sys.stdout.write(vers)
            return 0

    return 1


if __name__ == "__main__":
    sys.exit(main())
