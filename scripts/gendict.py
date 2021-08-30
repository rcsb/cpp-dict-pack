#!/usr/bin/env python

# Small script to combine dictionary component files

# Requires the PARTS file

import argparse
import os
import sys


class BuildDict(object):
    def __init__(self, srcdir, dstdir, dictname):
        self.__srcdir = srcdir
        self.__dstdir = dstdir
        self.__dictname = dictname
        pass

    def __get_parts(self):
        """Determine ordered list of parts"""
        parts = []
        with open(os.path.join(self.__srcdir, self.__dictname + ".PARTS"),
                  "r") as fin:
            for line in fin:
                line = line.strip()
                pth = os.path.join(self.__srcdir, line)
                parts.append(pth)
        return parts
        
    def get_deps(self):
        parts = self.__get_parts()
        return parts

    def __getoutput(self):
        return os.path.join(self.__dstdir, self.__dictname + ".dic")
    
    def get_outputs(self):
        outputs = [self.__getoutput()]
        return outputs

    def generate(self):
        parts = self.__get_parts()
        if not os.path.exists(self.__dstdir):
            os.makedirs(self.__dstdir)
        outpath = self.__getoutput()
        dname = self.__dictname + ".dic"
        with open(outpath, "w") as fout:
            fout.write("###########################################################################\n")
            fout.write("#\n")
            fout.write("# File:  %s\n" % dname)
            fout.write("# Date:  %s\n" % "2020-1-1")
            fout.write("#\n")
            fout.write("# Created from files in module dict-%s unless noted:\n" % dname)
            for p in parts:
                fout.write("#        %s   \n" % os.path.basename(p))
            fout.write("#\n")
            fout.write("###########################################################################\n")
            fout.write(" \n")
            fout.write(" \n")

            for p in parts:
                with open(p, "r") as fin:
                    fout.write(fin.read())


def main():
    parser = argparse.ArgumentParser(
        description = "Builds the dictionary by combinig dictionary parts",
        formatter_class = argparse.ArgumentDefaultsHelpFormatter
        )
    parser.add_argument('-s', '--source-dir', type=str, required=True,
                        help="Source directory of dictionary")
    parser.add_argument('-o', '--output-dir', type=str, required=True,
                        help='Output directory for the generated source files.')
    parser.add_argument('--dict-name', type=str, required=True,
                        help='Name of dictionaty base')
    parser.add_argument('--print-dependencies', action='store_true',
                        help='Prints a space separated list of file dependencies, used for CMake integration')
    parser.add_argument('--print-outputs', action='store_true',
                        help='Prints a space separated list of file outputs, used for CMake integration')

    args = parser.parse_args()
    #sys.stderr.write("%s\n" % args)

    bd = BuildDict(args.source_dir, args.output_dir, args.dict_name)

    if args.print_dependencies:
        deps = bd.get_deps()
        sys.stdout.write(';'.join(deps))
        return 0

    if args.print_outputs:
        outputs = bd.get_outputs()
        sys.stdout.write(';'.join(outputs))
        return 0

    bd.generate()
    return 0

if __name__ == "__main__":
    sys.exit(main())
    
