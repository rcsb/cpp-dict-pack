#!/usr/bin/env python

# Small script to provide dictionary info based on configuration
import argparse
import os
import sys
import re

from DictConfig import DictConfig

def main():
    parser = argparse.ArgumentParser(
        description="Retrieves information about a dictionary",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument("--dictname", type=str, required=True,
                        help="Name dictionary")
    parser.add_argument('--print-url', action='store_true',
                        help='Prints the url to download dictionary')
    parser.add_argument('--print-suppress-xml', action='store_true',
                        help="Prints True if XML support should not be generated for this dictionary")

    args = parser.parse_args()
    # sys.stderr.write("%s\n" % args)

    dc = DictConfig()

    if args.print_url:
        url = dc.get_url(args.dictname)
        if url:
            sys.stdout.write(url)
            return 0
        return 1

    if args.print_suppress_xml:
        val = dc.should_suppress_xml(args.dictname)
        if val:
            sys.stdout.write("True")
        else:
            sys.stdout.write("False")
        return 0


    return 1


if __name__ == "__main__":
    sys.exit(main())
