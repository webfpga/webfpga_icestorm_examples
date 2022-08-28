#!/usr/bin/env python3

# Copyright 2022 Google LLC
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# author: Sarah Clark <sarahclark@google.com>

"""
Parses the @MAP_IO directive in a Verilog file and writes a Physical Constraints file (.pcf).
"""
import argparse
import logging
import re

map_comment = re.compile(r'(?i)\s*//\s*@MAP_IO\s+(\w+)(\[\d+\])?\s+(\d+)')

PCF_HEADER = """
set_io -nowarn WF_LED       31
set_io -nowarn WF_CLK       35
set_io -nowarn WF_BUTTON    42
set_io -nowarn WF_NEO       32
set_io -nowarn WF_CPU1      11
set_io -nowarn WF_CPU2      12
set_io -nowarn WF_CPU3      13
set_io -nowarn WF_CPU4      10
"""


def main():
    """Parse the command line and process the files"""
    parser = argparse.ArgumentParser(allow_abbrev=False)

    group = parser.add_mutually_exclusive_group()
    group.add_argument("-v", "--verbose", help="display all files processed",
                       action="store_const", const=logging.INFO, dest='loglevel')
    group.add_argument("-d", "--debug", help="display debugging information",
                       action="store_const", const=logging.DEBUG, dest='loglevel')

    parser.add_argument('-o', '--output', default='pinmap.pcf',
                        help='output file with .pcf extension')
    parser.add_argument("-n", "--dry-run", help="examine files without changing",
                        action="store_true")
    parser.add_argument("file", nargs=1, help="file to check")
    args = parser.parse_args()
    logging.basicConfig(level=args.loglevel or logging.WARNING)

    if args.dry_run:
        logging.info("Dry run -- no files will be overwritten")

    symtable = []
    for fname in args.file:
        with open(fname) as source_file:
            logging.info(r"in: %s", fname)
            symtable = [mapping for line in source_file if (
                mapping := get_mapping(line)) is not None]

    if not symtable:
        logging.warning('No @MAP_IO statements found for %s', args.output)

    if not args.dry_run:
        logging.info(r'out: %s', args.output)
        with open(args.output, mode='wt') as pcf_file:
            pcf_file.write(PCF_HEADER)
            for item in symtable:
                pcf_file.write(item.to_set_io())


def get_mapping(line):
    """ Extract the mapping for this line. Returns None if not a map directive"""
    match_result = map_comment.match(line)
    if match_result is None:
        return None
    key = match_result.group(1)
    index = match_result.group(2)
    value = int(match_result.group(3))
    if index is not None:
        index = int(index.removeprefix('[').removesuffix(']'))
    return MapSpec(key, value, index)


class MapSpec:
    """Holds the values from the @MAP_IO statement"""

    def __init__(self, key, value, index=None) -> None:
        # Map external pin 1 to internal pin 17, etc.
        pin_map = [17, 16, 14, 23, 20, 19, 18, 21, 25, 26, 28, 27, 34, 35,
                   36, 37, 40, 44, 46, 47, 45, 48, 2, 3, 4, 9, 6, 43, 41, 39, 38, 15]
        self.symbol = f"key${index}" if index is not None else key
        self.base_name = key
        self.ext_pin = value
        self.int_pin = pin_map[value-1]
        self.index = index

    def __hash__(self):
        return hash((self.symbol))

    def to_set_io(self) -> str:
        return f"set_io\t{self.symbol}\t{self.int_pin}\n"


if __name__ == '__main__':
    main()
